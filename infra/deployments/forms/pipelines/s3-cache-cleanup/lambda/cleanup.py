import json
import os
import boto3
from botocore.exceptions import ClientError

s3 = boto3.client('s3')

def validate_namespace_config(namespace_config):
    """Validate namespace configuration structure."""
    if not isinstance(namespace_config, dict):
        raise ValueError(f"Namespace config must be a dict, got {type(namespace_config)}")

    if 'name' not in namespace_config:
        raise ValueError(f"Namespace config missing required 'name' key: {namespace_config}")

    if 'keep_newest' not in namespace_config:
        raise ValueError(f"Namespace config missing required 'keep_newest' key: {namespace_config}")

    keep_newest = namespace_config['keep_newest']
    if not isinstance(keep_newest, int) or keep_newest < 0:
        raise ValueError(f"keep_newest must be a non-negative integer, got: {keep_newest}")

    return True

def handler(event, context):
    """Clean up old CodeBuild cache objects, keeping only the newest N per namespace."""
    bucket_name = os.environ['BUCKET_NAME']

    # Parse and validate namespace configuration
    try:
        namespaces = json.loads(os.environ['NAMESPACES'])
        if not isinstance(namespaces, list):
            raise ValueError(f"NAMESPACES must be a JSON array, got {type(namespaces)}")

        for namespace_config in namespaces:
            validate_namespace_config(namespace_config)
    except (json.JSONDecodeError, ValueError) as e:
        print(f"ERROR: Invalid NAMESPACES configuration: {e}")
        return {
            'statusCode': 400,
            'body': json.dumps(f'Invalid configuration: {str(e)}')
        }

    print(f"Starting cache cleanup for bucket: {bucket_name}")

    overall_success = True
    results = []

    for namespace_config in namespaces:
        namespace = namespace_config['name']
        keep_newest = namespace_config['keep_newest']
        namespace_result = {
            'namespace': namespace,
            'success': False,
            'objects_found': 0,
            'objects_deleted': 0,
            'errors': []
        }

        print(f"Processing namespace: {namespace}, keeping {keep_newest} newest objects")

        try:
            # List all objects in this namespace
            objects = []
            paginator = s3.get_paginator('list_objects_v2')

            try:
                for page in paginator.paginate(Bucket=bucket_name, Prefix=f"{namespace}/"):
                    if 'Contents' in page:
                        objects.extend(page['Contents'])
            except ClientError as e:
                error_msg = f"Failed to list objects: {e}"
                print(f"ERROR in namespace {namespace}: {error_msg}")
                namespace_result['errors'].append(error_msg)
                overall_success = False
                results.append(namespace_result)
                continue

            namespace_result['objects_found'] = len(objects)

            if not objects:
                print(f"No objects found in namespace: {namespace}")
                namespace_result['success'] = True
                results.append(namespace_result)
                continue

            # Sort by LastModified descending (newest first)
            objects.sort(key=lambda x: x['LastModified'], reverse=True)

            # Keep newest N, delete the rest
            to_delete = objects[keep_newest:]

            print(f"Found {len(objects)} objects, deleting {len(to_delete)} old objects")

            if to_delete:
                # Delete in batches of 1000 (S3 limit)
                for i in range(0, len(to_delete), 1000):
                    batch = to_delete[i:i+1000]
                    delete_objects = [{'Key': obj['Key']} for obj in batch]

                    try:
                        response = s3.delete_objects(
                            Bucket=bucket_name,
                            Delete={'Objects': delete_objects}
                        )

                        # Check for partial failures
                        deleted = response.get('Deleted', [])
                        errors = response.get('Errors', [])

                        namespace_result['objects_deleted'] += len(deleted)

                        if errors:
                            for error in errors:
                                error_msg = f"Failed to delete {error['Key']}: {error['Code']} - {error['Message']}"
                                print(f"ERROR: {error_msg}")
                                namespace_result['errors'].append(error_msg)
                            overall_success = False

                        print(f"Deleted {len(deleted)} objects in batch")
                        if errors:
                            print(f"Failed to delete {len(errors)} objects in batch")

                    except ClientError as e:
                        error_msg = f"Failed to delete batch: {e}"
                        print(f"ERROR: {error_msg}")
                        namespace_result['errors'].append(error_msg)
                        overall_success = False

            namespace_result['success'] = len(namespace_result['errors']) == 0
            results.append(namespace_result)

        except Exception as e:
            error_msg = f"Unexpected error processing namespace: {str(e)}"
            print(f"ERROR in namespace {namespace}: {error_msg}")
            namespace_result['errors'].append(error_msg)
            overall_success = False
            results.append(namespace_result)

    # Summary
    print(f"\nCleanup summary:")
    for result in results:
        status = "SUCCESS" if result['success'] else "FAILED"
        print(f"  {result['namespace']}: {status} - Found: {result['objects_found']}, Deleted: {result['objects_deleted']}")
        if result['errors']:
            print(f"    Errors: {len(result['errors'])}")

    return {
        'statusCode': 200 if overall_success else 500,
        'body': json.dumps({
            'message': 'Cache cleanup completed' if overall_success else 'Cache cleanup completed with errors',
            'results': results
        })
    }

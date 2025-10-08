#!/usr/bin/env bash

# set -euo xtrace
set -euo pipefail
script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
deployments_dir="$(realpath "${script_dir}/../infra/deployments/")"

environment=""

usage() {
    cat <<EOF >&2
Usage: $0 -e environment

This helper script checks for existing auth0 aws access keys (for SES) in a given
environment. To rotate an access key we need to:
1. Remove the key from the terraform state file
2. Deploy the "ses" and "auth0" roots (ideally via the pipelines)
This script helps with step 1.
EOF
    exit 1
}

# Parse args
while getopts "e:" opt; do
    case "${opt}" in
        e)
            environment="${OPTARG}"
            ;;
        *)
            usage
            ;;
    esac

done

access_keys=$(aws iam list-access-keys --user-name auth0 | jq -rc '.AccessKeyMetadata[] | {AccessKeyId , CreateDate, Status}')

access_keys_count=$(echo "$access_keys" | jq -s 'map(.) | length')

echo "Access keys for auth0:"
for key in $( echo "$access_keys" | jq -r '.AccessKeyId'); do
  last_used_date=$(aws iam get-access-key-last-used --access-key-id "${key}" | jq -rc '.AccessKeyLastUsed.LastUsedDate')
  echo "$access_keys" | jq -rc --arg ACCESSKEYID "${key}" --arg LASTUSEDDATE "${last_used_date}" 'select(.AccessKeyId | contains($ACCESSKEYID)) | . += {"LastUsedDate":$LASTUSEDDATE}'
done

echo "There is a maximum of 2 keys allowed."
if [[ $access_keys_count -gt 1 ]] ; then
  cat <<EOF
Number of existing access keys: $access_keys_count
You will need to delete a key before creating a new one
You can delete a key using: aws iam delete-access-key --user-name auth0 --access-key-id "AccessKeyId"
EOF
  exit 1
fi

echo "Initialising SES root"

terraform \
 -chdir="${deployments_dir}/forms/ses" \
 init \
 -reconfigure \
 -upgrade \
 -backend-config "${deployments_dir}/forms/account/tfvars/backends/${environment}.tfvars"

echo "The next step would remove module.ses.aws_iam_access_key.auth0 from the state file. This will allow us to generate a new access key automatically"

read -p "Would you like to continue?" -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    terraform -chdir="${deployments_dir}/forms/ses" state rm module.ses.aws_iam_access_key.auth0
    echo "You can now run the forms pipeline in this environment to create a new access key"
fi

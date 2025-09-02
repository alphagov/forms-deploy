# secrets-spike-task (Terraform module)

This spike module provisions two minimal ECS Fargate services that consume Secrets Manager values from a central account and are intended to be force-redeployed by cross-account automation when secrets change.

It creates:

- One ECS cluster.
- Two services and task definitions: `catlike` and `doglike`.
- CloudWatch Logs log groups for each service.
- Minimal IAM roles for task execution and task access to Secrets Manager (scoped per secret ARN).
- A cross-account "deployer" role that the central secrets account can assume to call `ecs:UpdateService` with `forceNewDeployment=true`.

Security posture (spike):

- Each task has access only to its own provided Secret ARN.
- No explicit KMS permissions are granted; Secrets Manager decrypts on behalf of the caller.
- The deployer role allows `ecs:UpdateService`/`DescribeServices` only for the two created services and the created cluster.

## Inputs

- `name_prefix` (string, required): Prefix for resource names, e.g. `secrets-spike`.
- `region` (string, required): AWS region.
- `vpc_id` (string, required)
- `private_subnet_ids` (list(string), required)
- `security_group_ids` (list(string), required)
- `assign_public_ip` (bool, default `false`)
- `cpu` (number, default `256`)
- `memory` (number, default `512`)
- `desired_count` (number, default `1`)
- `container_image` (string, optional): If omitted, a public BusyBox image is used.
- `log_retention_days` (number, default `7`)
- `secrets` (object, required):
  - `catlike_arn` (string)
  - `doglike_arn` (string)
- `secrets_account_id` (string, required): Account that assumes the deployer role.
- `task_execution_role_additional_policies` (list(string), default `[]`)
- `task_role_additional_policies` (list(string), default `[]`)
- `enable_service_auto_scaling` (bool, default `false`)
- `autoscaling_min_capacity` (number, default `1`)
- `autoscaling_max_capacity` (number, default `2`)
- `autoscaling_target_cpu` (number, default `50`)
- `enable_execute_command` (bool, default `false`)

## Outputs

- `cluster_name`, `cluster_arn`
- `catlike_service_arn`, `catlike_service_name`
- `doglike_service_arn`, `doglike_service_name`
- `deployer_role_arn`
- `log_group_catlike`, `log_group_doglike`

## Example

See `examples/basic`:

```hcl
module "secrets_spike_task" {
  source = "../../"

  name_prefix         = "secrets-spike"
  region              = "eu-west-2"
  vpc_id              = "vpc-1234567890abcdef0"
  private_subnet_ids  = ["subnet-111", "subnet-222"]
  security_group_ids  = ["sg-abc123"]

  secrets = {
    catlike_arn = "arn:aws:secretsmanager:eu-west-2:123456789012:secret:/spikesecrets/catlike/dummy-secret-AbCdEf"
    doglike_arn = "arn:aws:secretsmanager:eu-west-2:123456789012:secret:/spikesecrets/doglike/dummy-secret-GhIjKl"
  }

  secrets_account_id = "210987654321"
}
```

## Notes

- The container prints only the first 8 characters of the secret via `${DUMMY_SECRET:0:8}` every ~20 seconds.
- EventBridge rules and cross-account invocation reside in the central secrets account (out of scope here). Provide `deployer_role_arn` to that automation to call `ecs:UpdateService` with `forceNewDeployment=true` against the appropriate service.

## Testing steps

1. Deploy the module with both secret ARNs.
2. Wait for both services to reach `RUNNING`.
3. Check CloudWatch Logs in the two log groups for lines like `secret head: XXXXXXXX`.
4. Update a secret value in the central account and trigger the automation to assume the deployer role and call `UpdateService`. Confirm a new deployment occurs and the logged head changes.
5. Negative test: swap ARNs between services and redeploy; observe `AccessDeniedException` for `GetSecretValue` in logs/events.

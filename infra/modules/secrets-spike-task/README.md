# secrets-spike-task (Terraform module)

This spike module provisions two minimal ECS Fargate services that consume Secrets Manager values from a central account and auto-redeploy when secrets change. Per-service Lambda functions in the env account listen to Events from the deploy account via EventBridge forwarders and call `ecs:UpdateService`.

## Architecture

- **Deploy account**: Single EventBridge forwarder rule on default bus that forwards Secrets Manager change events to each environment account's default bus.
- **Environment account**: Local EventBridge rules on default bus that filter only the secrets referenced by that account's ECS services and invoke per-service Lambda to `ecs:UpdateService --force-new-deployment`.
- Two services and task definitions: `catlike` and `doglike`.
- Each service references secrets via ECS container definition `secrets[].valueFrom`.
- Local Lambda functions (`{env}-secrets-spike-catlike-redeploy` and `{env}-secrets-spike-doglike-redeploy`) triggered by local EventBridge rules.
- EventBridge bus policy on default bus allows deploy account to put events.

## What's included

- Two ECS Fargate clusters (one per service type)
- Two ECS services and task definitions
- IAM roles and policies for ECS execution/task
- CloudWatch log groups
- Local EventBridge rules that listen for Secrets Manager events
- Lambda functions that call `ecs:UpdateService` when their watched secrets change
- EventBridge bus policy allowing deploy account to forward events

## Variables

- `name_prefix` (string, required): Prefix for resource names, e.g. `dev-secrets-spike`.
- `region` (string, required): AWS region for deployment.
- `vpc_id` (string, required): VPC ID where resources will be deployed.
- `private_subnet_ids` (list, required): Private subnet IDs for ECS services.
- `security_group_ids` (list, required): Security group IDs for ECS tasks.
- `secrets_account_id` (string, required): Account ID where Secrets Manager resides and EventBridge events originate.
- `secrets` (object, required): Map containing:
  - `catlike_arn` (string)
  - `doglike_arn` (string)

Plus various optional variables for scaling, log retention, additional IAM policies, etc. The module always uses the public busybox image.

## Usage

```hcl
module "secrets_spike_task" {
  source = "../../../modules/secrets-spike-task"

  name_prefix        = "dev-secrets-spike"
  region             = "eu-west-2"
  vpc_id             = "vpc-12345"
  private_subnet_ids = ["subnet-12345", "subnet-67890"]
  security_group_ids = ["sg-12345"]

  secrets = {
    catlike_arn = "arn:aws:secretsmanager:eu-west-2:123456789012:secret:/spikesecrets/catlike/dummy-secret-AbCdEf"
    doglike_arn = "arn:aws:secretsmanager:eu-west-2:123456789012:secret:/spikesecrets/doglike/dummy-secret-GhIjKl"
  }

  secrets_account_id = "123456789012"
}
```

## Outputs

- `catlike_cluster_name`, `catlike_cluster_arn`
- `doglike_cluster_name`, `doglike_cluster_arn`
- `catlike_service_name`, `catlike_service_arn`
- `doglike_service_name`, `doglike_service_arn`
- `catlike_event_rule_name`, `catlike_event_rule_arn` (local rules)
- `doglike_event_rule_name`, `doglike_event_rule_arn` (local rules)
- `catlike_lambda_name`, `catlike_lambda_arn`
- `doglike_lambda_name`, `doglike_lambda_arn`
- `bus_policy_id`
- Log group names for both services

## Security posture (spike)

- Each task has access only to its own provided Secret ARN.
- No explicit KMS permissions are granted; Secrets Manager decrypts on behalf of the caller.
- Lambda functions have permissions to update only their specific ECS service.
- EventBridge bus policy allows only the deploy account to put events to the default bus.

## Testing steps

1. Deploy the module with both secret ARNs.
2. Wait for both services to reach `RUNNING`.
3. Check CloudWatch Logs in the two log groups for lines like `secret head: XXXXXXXX`.
4. Update a secret value in the deploy account. Confirm EventBridge forwarder → environment default bus → local rule → Lambda → ecs:UpdateService triggers and a new deployment occurs with the updated secret head.
5. Negative test: change an unrelated secret; no trigger should occur.

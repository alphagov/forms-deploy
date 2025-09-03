# redeploy-lambda submodule

Deploys a Lambda that forces an ECS service redeploy when specific Secrets Manager secrets change. EventBridge rules are created on the local default bus in the environment account and target this Lambda.

Inputs (key):

- name: Base name for resources (function, rule, log group)
- cluster_arn, service_arn: ECS targets
- secret_arns: List of secret ARNs to watch (used for Lambda environment)
- secret_filters: List of secret ARNs and names for EventBridge rule filtering
- log_retention_days: Log retention (default 14 days)

Outputs:

- lambda_name, lambda_arn
- rule_name, rule_arn (local default bus)

Notes:

- Creates local EventBridge rule on default bus that filters by provided secret ARNs/names
- Adds lambda:InvokeFunction permission for the local EventBridge rule ARN
- Event pattern filters Secrets Manager API calls by provided secret filters

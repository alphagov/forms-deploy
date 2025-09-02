# redeploy-lambda submodule

Deploys a Lambda that forces an ECS service redeploy when specific Secrets Manager secrets change. EventBridge rules are created on a remote, shared bus in the secrets account and target this Lambda in the environment account.

Inputs (key):

- region: AWS region
- cluster_arn, service_arn: ECS targets
- secret_arns: List of secret ARNs to watch
- secrets_account_id: ID of the account hosting the shared EventBridge bus
- secrets_account_bus_name: Bus name (default "default")
- org_rule_prefix_mode: Prefix rule name with caller account ID (default true)
- rule_name_suffix_prefix: e.g. module name prefix
- rule_suffix: e.g. "catlike-redeploy"

Outputs:

- lambda_name, lambda_arn
- rule_name, rule_arn (remote bus)

Notes:

- Adds lambda:InvokeFunction permission for the remote EventBridge rule ARN.
- Event pattern filters Secrets Manager API calls by provided secret ARNs.

# Shared EventBridge Bus for Secrets Events

This stack runs in the secrets account and attaches a resource policy to the default EventBridge bus to let any account in the AWS Organization create and manage only their own namespaced rules and targets. This enables environment accounts to react to `Secrets Manager` changes by targeting Lambdas in their own account that force ECS service redeploys.

## What this provides

- Uses the default EventBridge bus in the secrets account (no custom bus).
- Resource-based policy attached to the bus that allows principals in your AWS Organization (via `aws:PrincipalOrgID`) to:
  - Manage rules: `events:PutRule`, `DeleteRule`, `EnableRule`, `DisableRule`, `DescribeRule`, `TagResource`, `UntagResource`, `ListTagsForResource`.
  - Manage targets: `events:PutTargets`, `RemoveTargets`, `ListTargetsByRule`.
- Guardrails:
  - Rule names must start with the caller's account ID (e.g. `123456789012-secrets-spike-catlike-redeploy`).
  - Targets must be Lambda functions in the caller's account only.

## Variables

- No Organization ID variable is needed. The stack derives it via `aws_organizations_organization` and therefore requires Organizations permissions in the secrets account.
- `region` (required): AWS region.
- `enable_rule_management` (default `true`): Toggle to attach the policy.
- `rule_name_prefix` (default `secrets-spike`): For examples; enforcement is by account ID prefix.

## Outputs

- `shared_event_bus_arn`: ARN of the default bus.
- `shared_event_bus_policy_id`: ID of the policy resource (empty if disabled).

## How environment accounts use this bus

1. Create a rule on the shared bus (in the secrets account) with a name prefixed by your AWS account ID, e.g. `123456789012-secrets-spike-catlike-redeploy`.
2. Use an event pattern that matches your watched secrets. Example fragment:

```
{
  "source": ["aws.secretsmanager"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["secretsmanager.amazonaws.com"],
    "eventName": ["PutSecretValue","UpdateSecretVersionStage","RotateSecret"],
    "requestParameters": {
      "secretId": [
        "<full-secret-arn-1>",
        "<full-secret-arn-2>",
        "<short-name-if-used>"
      ]
    }
  }
}
```

3. Add your Lambda as a target to your rule. The policy enforces that targets are Lambda functions in your own account only.
4. Grant the secrets account's EventBridge permission to invoke your Lambda. Example:

- Terraform (environment account):

```
resource "aws_lambda_permission" "allow_invoke_from_secrets_bus" {
  statement_id  = "AllowInvokeFromSecretsBus"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redeploy.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:<region>:<secrets-account-id>:rule/123456789012-secrets-spike-catlike-redeploy"
}
```

5. Derive your `secretId` match list from your ECS container definitions (the `secrets.valueFrom` values), including full ARNs and any short names you need.

## Security guarantees

- Only accounts in `org_id` can manage rules/targets on the bus.
- Accounts can create and manage rules only with names prefixed by their own account ID.
- Accounts can attach targets only for Lambda functions in their own account.

## Cleanup and guardrails

- To disable rule management, set `enable_rule_management = false` and apply; this detaches the policy.
- Inspect current rules and targets via CLI:

```
aws events list-rules --event-bus-name default
aws events list-targets-by-rule --event-bus-name default --rule <rule-name>
```

## Provider

- This stack runs in the secrets account; provider is scoped by `region` only (no assume-role).

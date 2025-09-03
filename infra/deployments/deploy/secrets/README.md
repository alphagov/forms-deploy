# Shared EventBridge Bus for Secrets Events (custom bus)

This stack runs in the secrets (deploy) account and provisions a custom EventBridge bus `secrets-shared`. A single forwarder rule on the default bus forwards Secrets Manager change events to the custom bus. Org members can then create namespaced rules and Lambda targets on `secrets-shared` only.

## What this provides

- Custom EventBridge bus: `secrets-shared`.
- Forwarder on default bus → forwards Secrets Manager events to `secrets-shared`.
- Resource-based policy on `secrets-shared` that allows principals in your AWS Organization (via `aws:PrincipalOrgID`) to:
  - Manage rules: `events:PutRule`, `DeleteRule`, `EnableRule`, `DisableRule`, `DescribeRule` (namespaced by account-ID prefix).
  - Manage targets: `events:PutTargets`, `RemoveTargets`, `ListTargetsByRule` (Lambda-only, in caller’s account).
  - Tag rules: `events:TagResource`, `UntagResource`, `ListTagsForResource`.
- Guardrails:
  - Rule names must start with the caller's account ID (e.g. `123456789012-secrets-spike-catlike-redeploy`).
  - Targets must be Lambda functions in the caller's account only.

## Variables

- Organization ID is auto-derived via `aws_organizations_organization` (requires Organizations permissions in this account).
- `region` (required): AWS region.
- `enable_rule_management` (default `true`): Toggle to attach the policy.

## Outputs

- `shared_event_bus_arn`: ARN of the custom bus.
- `shared_event_bus_name`: Name of the custom bus.
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
        "<full-secret-arn-2>"
      ]
    }
  }
}
```

3. Add your Lambda as a target to your rule. The policy enforces that targets are Lambda functions in your own account only.
4. Grant the secrets account's EventBridge permission to invoke your Lambda. Example (env account):

```
resource "aws_lambda_permission" "allow_invoke_from_shared_bus" {
  statement_id  = "AllowInvokeFromSharedBus"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redeploy.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:<region>:<secrets-account-id>:rule/secrets-shared/123456789012-secrets-spike-catlike-redeploy"
}
```

5. Derive your `secretId` match list from your ECS container definitions (the `secrets.valueFrom` values).

## Validation steps

- After apply in the secrets account:
  - `secrets-shared` bus exists.
  - A rule on default forwards matching events to `secrets-shared` (check via CloudTrail or metrics).
  - Policy attached on `secrets-shared`.
- From an environment account:
  - Create a namespaced rule on `secrets-shared` with your secretId filters and a Lambda target.
  - Add the lambda permission referencing the custom bus rule ARN.
  - Update a secret: event → secrets-shared → env rule → env Lambda → ECS UpdateService → new tasks.

## Provider

- This stack runs in the secrets account; provider is scoped by `region` only.

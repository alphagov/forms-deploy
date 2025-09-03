# EventBridge Forwarder for Secrets Events (deploy account)

This stack runs in the secrets (deploy) account and forwards Secrets Manager change events from the default bus to each environment account's default bus. Environment accounts then handle events locally with their own rules and Lambda functions.

## Architecture

- **Deploy account**: Single EventBridge forwarder rule on default bus that forwards Secrets Manager change events to each environment account's default bus using `module.all-accounts.environment_accounts_id`.
- **Environment accounts**: Local EventBridge rules on default bus that filter only the secrets referenced by that account's ECS services and invoke per-service Lambda to `ecs:UpdateService --force-new-deployment`.

## What this provides

- EventBridge forwarder rule on the default bus that matches Secrets Manager change events.
- One EventBridge target per environment account that forwards events to that account's default bus.
- Reuses the existing `event-bridge-actor` IAM role from the coordination stack for cross-account forwarding.
- Automatic discovery of environment accounts via `module.all-accounts.environment_accounts_id`.

## Event Pattern

The forwarder rule matches:

```json
{
  "source": ["aws.secretsmanager"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["secretsmanager.amazonaws.com"],
    "eventName": ["PutSecretValue", "UpdateSecretVersionStage", "RotateSecret"]
  }
}
```

## Variables

- No configuration variables required. Environment accounts are automatically discovered via `module.all-accounts.environment_accounts_id`.
- Organization ID is auto-derived via `aws_organizations_organization` (requires Organizations permissions in this account).

## Dependencies

- **Coordination stack**: This stack depends on the coordination stack being deployed first, as it reuses the `event-bridge-actor` IAM role created there.
- **Organization permissions**: Requires Organizations permissions in the deploy account to auto-discover environment accounts.
- **Environment EventBridge policies**: This forwarder depends on each environment account having an EventBridge bus policy that allows the deploy account to put events. Currently this is provided by `forms/pipelines/eventbridge.tf` in each environment.

## Important Notes for Future Implementation

⚠️ **Spike Architecture Dependency**: This implementation currently relies on the existing EventBridge bus policy created by `forms/pipelines/eventbridge.tf` in environment accounts.

**If this secrets forwarding methodology is adopted for production use beyond the spike**:

1. The running order in `infra/deployments/running-order.yml` may need updating to ensure EventBridge policies are deployed before secrets forwarding is activated
2. Consider creating a dedicated EventBridge policy module that can be deployed early in the environment setup phase
3. The dependency on pipelines deployment should be made explicit in the running order documentation

## Outputs

- `forward_rule_name`: Name of the EventBridge forwarder rule on default bus
- `forward_rule_arn`: ARN of the EventBridge forwarder rule on default bus
- `forward_target_arns_by_env`: Map of environment names to target default bus ARNs
- `forward_role_arn`: ARN of the IAM role used by EventBridge to forward events (reused from coordination stack)

## Environment Account Setup

Each environment account must:

1. **EventBridge bus policy**: Already created by `forms/pipelines/eventbridge.tf` deployment which allows the deploy account to put events to the default bus.

2. Create local EventBridge rules on the default bus that filter for their specific secrets and target their Lambda functions.

3. Create Lambda functions that call `ecs:UpdateService --force-new-deployment` for their services.

## Validation steps

- After apply in the deploy account:
  - Forwarder rule exists on default bus with correct event pattern
  - One target exists per environment account pointing to their default bus
  - IAM role exists with permissions to put events to all environment default buses
- Test end-to-end:
  - Update a secret in the deploy account
  - Verify: deploy default bus → forwarder → env default bus → env rule → env Lambda → ecs:UpdateService

## Security

- Cross-account EventBridge delivery uses IAM role with least-privilege permissions
- Environment accounts control their own event processing via local rules and bus policies
- No shared infrastructure or complex cross-account policies required

## Provider

- This stack runs in the deploy account; provider is scoped by `region` only.

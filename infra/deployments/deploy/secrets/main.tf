# Access to module.all-accounts.environment_accounts_id
module "all_accounts" {
  source = "../../../modules/all-accounts"
}

# Current account and region data
data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

# Forwarder rule on default bus for Secrets Manager events
resource "aws_cloudwatch_event_rule" "forward_secrets" {
  name           = "forward-secrets-to-environments"
  event_bus_name = "default"
  event_pattern = jsonencode({
    source      = ["aws.secretsmanager"],
    detail-type = ["AWS API Call via CloudTrail"],
    detail = {
      eventSource = ["secretsmanager.amazonaws.com"],
      eventName   = ["PutSecretValue", "UpdateSecretVersionStage", "RotateSecret"]
    }
  })
}

# Targets - one per environment account
resource "aws_cloudwatch_event_target" "forward_to_env" {
  for_each = module.all_accounts.environment_accounts_id

  rule           = aws_cloudwatch_event_rule.forward_secrets.name
  event_bus_name = "default"
  target_id      = "${each.key}-default-bus"
  arn            = "arn:aws:events:${data.aws_region.this.name}:${each.value}:event-bus/default"
}

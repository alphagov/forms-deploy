## Default event bus in the deploy account
data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

## Current account and region
data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

## Organization (for org-scoped policy)
data "aws_organizations_organization" "this" {}

## Create the shared custom bus where env accounts will create rules/targets
resource "aws_cloudwatch_event_bus" "shared" {
  name = "secrets-shared"
}

## Forwarder: default bus → custom shared bus (same account)
resource "aws_cloudwatch_event_rule" "forward_secrets" {
  name           = "forward-secrets-to-secrets-shared"
  event_bus_name = data.aws_cloudwatch_event_bus.default.name
  event_pattern = jsonencode({
    source        = ["aws.secretsmanager"],
    "detail-type" = ["AWS API Call via CloudTrail"],
    detail = {
      eventSource = ["secretsmanager.amazonaws.com"],
      eventName   = ["PutSecretValue", "UpdateSecretVersionStage", "RotateSecret"]
    }
  })
}

resource "aws_cloudwatch_event_target" "forward_to_shared" {
  rule           = aws_cloudwatch_event_rule.forward_secrets.name
  event_bus_name = data.aws_cloudwatch_event_bus.default.name
  arn            = aws_cloudwatch_event_bus.shared.arn
}

## Org-scoped policy on the custom bus, namespaced by caller account ID
resource "aws_cloudwatch_event_bus_policy" "org_rule_mgmt" {
  count          = var.enable_rule_management ? 1 : 0
  event_bus_name = aws_cloudwatch_event_bus.shared.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowOrgAccountsToManageNamespacedRules",
        Effect    = "Allow",
        Principal = { "AWS" : "*" },
        Action    = ["events:PutRule", "events:DeleteRule", "events:EnableRule", "events:DisableRule", "events:DescribeRule"],
        Resource = [
          aws_cloudwatch_event_bus.shared.arn,
          "arn:aws:events:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:rule/${aws_cloudwatch_event_bus.shared.name}/*"
        ],
        Condition = {
          StringEquals = { "aws:PrincipalOrgID" = data.aws_organizations_organization.this.id },
          StringLike   = { "events:ruleName" = ["${"${"aws:PrincipalAccount"}"}-*"] }
        }
      },
      {
        Sid       = "AllowOrgAccountsToManageTargetsForTheirRules",
        Effect    = "Allow",
        Principal = { "AWS" : "*" },
        Action    = ["events:PutTargets", "events:RemoveTargets", "events:ListTargetsByRule"],
        Resource  = "arn:aws:events:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:rule/${aws_cloudwatch_event_bus.shared.name}/*",
        Condition = {
          StringEquals       = { "aws:PrincipalOrgID" = data.aws_organizations_organization.this.id },
          StringLike         = { "events:ruleName" = ["${"${"aws:PrincipalAccount"}"}-*"] },
          StringLikeIfExists = { "events:TargetArn" = ["arn:aws:lambda:*:${"${"aws:PrincipalAccount"}"}:function:*"] }
        }
      },
      {
        Sid       = "AllowOrgAccountsToTagRules",
        Effect    = "Allow",
        Principal = { "AWS" : "*" },
        Action    = ["events:TagResource", "events:UntagResource", "events:ListTagsForResource"],
        Resource  = "arn:aws:events:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:rule/${aws_cloudwatch_event_bus.shared.name}/*",
        Condition = {
          StringEquals       = { "aws:PrincipalOrgID" = data.aws_organizations_organization.this.id },
          StringLikeIfExists = { "events:ruleName" = ["${"${"aws:PrincipalAccount"}"}-*"] }
        }
      },
      {
        Sid       = "DenyTargetsToOtherAccounts",
        Effect    = "Deny",
        Principal = { "AWS" : "*" },
        Action    = ["events:PutTargets"],
        Resource  = "arn:aws:events:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:rule/${aws_cloudwatch_event_bus.shared.name}/*",
        Condition = {
          StringNotLikeIfExists = {
            "events:TargetArn" = ["arn:aws:lambda:*:${"${"aws:PrincipalAccount"}"}:function:*"]
          }
        }
      }
    ]
  })
}

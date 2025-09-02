# Default event bus in the deploy account
# We reference the default bus via data; do not create a custom bus.
data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

# Derive the AWS Organization ID. Requires Organizations permissions in the deploy account.
data "aws_organizations_organization" "this" {}

# Build a resource policy that allows org accounts to manage only their namespaced rules
# and attach targets that are Lambda functions in their own accounts.
# This attaches to the default event bus.
resource "aws_cloudwatch_event_bus_policy" "org_rule_mgmt" {
  count          = var.enable_rule_management ? 1 : 0
  event_bus_name = data.aws_cloudwatch_event_bus.default.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowOrgAccountsToManageNamespacedRules",
        Effect    = "Allow",
        Principal = { "AWS" : "*" },
        Action = [
          "events:PutRule",
          "events:DeleteRule",
          "events:EnableRule",
          "events:DisableRule",
          "events:DescribeRule",
          "events:TagResource",
          "events:UntagResource",
          "events:ListTagsForResource"
        ],
        Resource = [
          data.aws_cloudwatch_event_bus.default.arn,
          "${data.aws_cloudwatch_event_bus.default.arn}/rule/*"
        ],
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = data.aws_organizations_organization.this.id
          },
          StringLike = {
            # Require rule name to start with the caller's account ID
            # EventBridge evaluates this for rule APIs via the condition key events:ruleName
            "events:ruleName" = ["${"${"aws:PrincipalAccount"}"}-*"]
          }
        }
      },
      {
        Sid       = "AllowOrgAccountsToManageTargetsForTheirRules",
        Effect    = "Allow",
        Principal = { "AWS" : "*" },
        Action = [
          "events:PutTargets",
          "events:RemoveTargets",
          "events:ListTargetsByRule"
        ],
        Resource = "${data.aws_cloudwatch_event_bus.default.arn}/rule/*",
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = data.aws_organizations_organization.this.id
          },
          StringLikeIfExists = {
            # Only allow Lambda targets in caller's account
            "events:TargetArn" = ["arn:aws:lambda:*:${"${"aws:PrincipalAccount"}"}:function:*"]
          },
          StringLike = {
            # Ensure callers can only manage targets on their namespaced rules
            "events:ruleName" = ["${"${"aws:PrincipalAccount"}"}-*"]
          }
        }
      },
      {
        Sid       = "DenyTargetsToOtherAccounts",
        Effect    = "Deny",
        Principal = { "AWS" : "*" },
        Action = [
          "events:PutTargets"
        ],
        Resource = "${data.aws_cloudwatch_event_bus.default.arn}/rule/*",
        Condition = {
          StringNotLikeIfExists = {
            "events:TargetArn" = ["arn:aws:lambda:*:${"${"aws:PrincipalAccount"}"}:function:*"]
          }
        }
      }
    ]
  })
}

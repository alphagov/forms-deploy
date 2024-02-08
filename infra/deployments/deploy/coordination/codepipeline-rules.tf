locals {
  source_to_dest_accts = {
    "development" = [

    ]
    "staging" = ["dev", "prd", "ur"]
  }
}

resource "aws_cloudwatch_event_rule" "codepipeline_successes" {
  for_each = toset(["development", "staging", "production", "userresearch"])

  name        = "codepipeline-successes-from-${each.key}"
  description = "Match pipeline success events from the ${each.key} account"
  role_arn    = aws_iam_role.eventbridge_actor.arn

  event_pattern = jsonencode({
    source  = ["aws.codepipeline"],
    account = [local.other_accounts[each.key]]
    detail = {
      state = ["SUCCEEDED"],
    }
  })
}

resource "aws_cloudwatch_event_target" "codepipeline_successes_development_to_staging" {
  target_id = "from-development-to-staging"
  rule      = aws_cloudwatch_event_rule.codepipeline_successes["development"].name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:${local.other_accounts["staging"]}:event-bus/default"
}

resource "aws_cloudwatch_event_target" "codepipeline_successes_development_to_production" {
  target_id = "from-development-to-production"
  rule      = aws_cloudwatch_event_rule.codepipeline_successes["development"].name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:${local.other_accounts["production"]}:event-bus/default"
}

resource "aws_cloudwatch_event_target" "codepipeline_successes_development_to_userresearch" {
  target_id = "from-development-to-userresearch"
  rule      = aws_cloudwatch_event_rule.codepipeline_successes["development"].name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:${local.other_accounts["userresearch"]}:event-bus/default"
}

resource "aws_cloudwatch_event_target" "codepipeline_successes_staging_to_development" {
  target_id = "from-staging-to-development"
  rule      = aws_cloudwatch_event_rule.codepipeline_successes["staging"].name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:${local.other_accounts["development"]}:event-bus/default"
}

resource "aws_cloudwatch_event_target" "codepipeline_successes_staging_to_production" {
  target_id = "from-staging-to-production"
  rule      = aws_cloudwatch_event_rule.codepipeline_successes["staging"].name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:${local.other_accounts["production"]}:event-bus/default"
}

resource "aws_cloudwatch_event_target" "codepipeline_successes_staging_to_userresearch" {
  target_id = "from-staging-to-userresearch"
  rule      = aws_cloudwatch_event_rule.codepipeline_successes["staging"].name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:${local.other_accounts["userresearch"]}:event-bus/default"
}

resource "aws_cloudwatch_event_target" "codepipeline_successes_production_to_development" {
  target_id = "from-production-to-development"
  rule      = aws_cloudwatch_event_rule.codepipeline_successes["production"].name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:${local.other_accounts["development"]}:event-bus/default"
}

resource "aws_cloudwatch_event_target" "codepipeline_successes_production_to_staging" {
  target_id = "from-production-to-staging"
  rule      = aws_cloudwatch_event_rule.codepipeline_successes["production"].name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:${local.other_accounts["staging"]}:event-bus/default"
}

resource "aws_cloudwatch_event_target" "codepipeline_successes_production_to_userresearch" {
  target_id = "from-production-to-userresearch"
  rule      = aws_cloudwatch_event_rule.codepipeline_successes["production"].name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:${local.other_accounts["userresearch"]}:event-bus/default"
}

resource "aws_cloudwatch_event_target" "codepipeline_successes_userresearch_to_development" {
  target_id = "from-userresearch-to-development"
  rule      = aws_cloudwatch_event_rule.codepipeline_successes["userresearch"].name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:${local.other_accounts["development"]}:event-bus/default"
}

resource "aws_cloudwatch_event_target" "codepipeline_successes_userresearch_to_staging" {
  target_id = "from-userresearch-to-staging"
  rule      = aws_cloudwatch_event_rule.codepipeline_successes["userresearch"].name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:${local.other_accounts["staging"]}:event-bus/default"
}

resource "aws_cloudwatch_event_target" "codepipeline_successes_userresearch_to_production" {
  target_id = "from-userresearch-to-production"
  rule      = aws_cloudwatch_event_rule.codepipeline_successes["userresearch"].name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:${local.other_accounts["production"]}:event-bus/default"
}


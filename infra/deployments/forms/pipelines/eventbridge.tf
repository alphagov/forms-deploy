## Default bus policy
data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

data "aws_iam_policy_document" "allow_receiving_from_deploy_account" {
  statement {
    sid    = "AllowEventsFromDeployAcct"
    effect = "Allow"
    actions = [
      "events:PutEvents"
    ]
    resources = [data.aws_cloudwatch_event_bus.default.arn]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.deploy_account_id}:root"]
    }
  }
}

resource "aws_cloudwatch_event_bus_policy" "default_bus_policy" {
  policy         = data.aws_iam_policy_document.allow_receiving_from_deploy_account.json
  event_bus_name = "default"
}

resource "aws_cloudwatch_log_resource_policy" "allow_delivery_from_eventbridge" {
  policy_document = data.aws_iam_policy_document.log_group_policy.json
  policy_name     = "eventbridge-publishing-policy"
}

data "aws_iam_policy_document" "log_group_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      module.log_ecr_push_events.log_group_arn,
      "${module.log_ecr_push_events.log_group_arn}:*",

      module.log_codepipeline_events.log_group_arn,
      "${module.log_codepipeline_events.log_group_arn}:*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "delivery.logs.amazonaws.com"
      ]
    }
  }
}


## Log ECR events
module "log_ecr_push_events" {
  source = "../../../modules/eventbridge-log-to-cloudwatch"

  environment_name      = var.environment_name
  log_group_subject     = "ecr_push_events"
  dead_letter_queue_arn = data.terraform_remote_state.forms_environment.outputs.eventbridge_dead_letter_queue_arn
  event_pattern = jsonencode({
    source = ["aws.ecr", "uk.gov.service.forms"]
    detail = {
      action-type = ["PUSH"]
    }
  })
}

## Push CodePipeline events to deploy account
resource "aws_cloudwatch_event_rule" "codepipeline_events" {
  name        = "all-codepipeline-events-${var.environment_name}"
  description = "Match all Codepipeline events for ${var.environment_name}"
  role_arn    = aws_iam_role.eventbridge_actor.arn
  event_pattern = jsonencode({
    source = ["aws.codepipeline"],
    detail = {
      pipeline = [
        # We can have many envs in one account
        # and we don't want to duplicate events
        { "wildcard" : "*-${var.environment_name}" },
        { "wildcard" : "${var.environment_name}-*" }
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "forward_codepipeline_events_to_deploy_defualt_bus" {
  target_id = "${var.environment_name}-codepipeline-events-to-deploy-defualt-bus"
  rule      = aws_cloudwatch_event_rule.codepipeline_events.name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:${var.deploy_account_id}:event-bus/default"

  dead_letter_config {
    arn = data.terraform_remote_state.forms_environment.outputs.eventbridge_dead_letter_queue_arn
  }
}

module "log_codepipeline_events" {
  source = "../../../modules/eventbridge-log-to-cloudwatch"

  environment_name      = var.environment_name
  log_group_subject     = "codepipeline"
  dead_letter_queue_arn = data.terraform_remote_state.forms_environment.outputs.eventbridge_dead_letter_queue_arn

  event_pattern = aws_cloudwatch_event_rule.codepipeline_events.event_pattern
}

## Push custom CodeBuild run-e2e-tests RSpec output events to deploy account
resource "aws_cloudwatch_event_rule" "run_e2e_tests_events" {
  name        = "run-e2e-tests-events-${var.environment_name}"
  description = "Match CodeBuild run-e2e-tests events for ${var.environment_name}"
  role_arn    = aws_iam_role.eventbridge_actor.arn
  event_pattern = jsonencode({
    source      = ["custom"],
    detail-type = ["CodeBuild run-e2e-tests RSpec output"]
  })
}

resource "aws_cloudwatch_event_target" "forward_run_e2e_tests_events_to_deploy_default_bus" {
  target_id = "${var.environment_name}-run-e2e-tests-events-to-deploy-default-bus"
  rule      = aws_cloudwatch_event_rule.run_e2e_tests_events.name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:${var.deploy_account_id}:event-bus/default"

  dead_letter_config {
    arn = data.terraform_remote_state.forms_environment.outputs.eventbridge_dead_letter_queue_arn
  }
}


# Only needed for debugging, change local.log_e2e_test_events to true to enable
locals {
  log_e2e_test_events = false
}

module "log_e2e_test_events" {
  count = local.log_e2e_test_events ? 1 : 0

  source = "../../../modules/eventbridge-log-to-cloudwatch"

  environment_name      = var.environment_name
  log_group_subject     = "run_e2e_tests"
  dead_letter_queue_arn = data.terraform_remote_state.forms_environment.outputs.eventbridge_dead_letter_queue_arn

  event_pattern = aws_cloudwatch_event_rule.run_e2e_tests_events.event_pattern
}

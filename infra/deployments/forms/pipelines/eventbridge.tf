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
      identifiers = ["arn:aws:iam::711966560482:root"]
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
      module.log_terraform_application_success_events.log_group_arn
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

  environment_name  = var.environment_name
  log_group_subject = "ecr_push_events"
  event_pattern     = jsonencode({
    source = ["aws.ecr", "uk.gov.service.forms"]
    detail = {
      action-type = ["PUSH"]
    }
  })
}

## Push pipeline successes to deploy account
module "log_terraform_application_success_events" {
  source = "../../../modules/eventbridge-log-to-cloudwatch"

  environment_name  = var.environment_name
  log_group_subject = "terraform_application_success"
  event_pattern = jsonencode({
    source = ["uk.gov.service.forms"],
    detail-type = ["Terraform application succesful"]
  })
}

resource "aws_cloudwatch_event_rule" "terraform_application_succcesses" {
  name        = "all-terraform-application-success-events-${var.environment_name}"
  description = "Match all Terraform application successes for ${var.environment_name}"
  role_arn    = aws_iam_role.eventbridge_actor.arn
  event_pattern = jsonencode({
    source = ["uk.gov.service.forms"],
    detail-type = ["Terraform application succesful"]
  })
}

resource "aws_cloudwatch_event_target" "forward_terraform_application_success_to_deploy_defualt_bus" {
  target_id = "${var.environment_name}-forward-terraform-application-success-to-deploy-defualt-bus"
  rule      = aws_cloudwatch_event_rule.terraform_application_succcesses.name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = "arn:aws:events:eu-west-2:711966560482:event-bus/default"
}

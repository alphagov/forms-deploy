resource "aws_cloudwatch_event_rule" "distribute_ecr_events" {
  name        = "send-ecr-events-to-other-acounts"
  description = "Send ECR events to the event buses of the other accounts"
  role_arn    = aws_iam_role.eventbridge_actor.arn
  event_pattern = jsonencode({
    source = ["aws.ecr", "uk.gov.service.forms"]
    detail = {
      action-type = ["PUSH"]
    }
  })
}

resource "aws_cloudwatch_event_target" "other_account_event_bus" {
  for_each = local.other_accounts
  rule     = aws_cloudwatch_event_rule.distribute_ecr_events.name
  role_arn = aws_iam_role.eventbridge_actor.arn
  arn      = "arn:aws:events:eu-west-2:${each.value}:event-bus/default"
}
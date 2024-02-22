module "log_codepipeline_events" {
  source = "../../../modules/eventbridge-log-to-cloudwatch"

  environment_name      = "deploy"
  log_group_subject     = "codepipeline"
  dead_letter_queue_arn = aws_sqs_queue.event_bridge_dlq.arn

  event_pattern = jsonencode({
    source = ["aws.codepipeline"]
  })
}
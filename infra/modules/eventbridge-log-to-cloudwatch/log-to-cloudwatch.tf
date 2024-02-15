resource "aws_cloudwatch_log_group" "log_group" {
    name              = "/aws/events/${var.environment_name}/${var.log_group_subject}"
    retention_in_days = 14
}

resource "aws_cloudwatch_event_rule" "rule" {
    name          = "${var.environment_name}-${var.log_group_subject}"
    event_pattern = var.event_pattern
}

resource "aws_cloudwatch_event_target" "log_events_to_cloudwatch" {
    target_id = "${var.environment_name}-${var.log_group_subject}-log-to-cloudwatch"
    rule      = aws_cloudwatch_event_rule.rule.name
    arn       = aws_cloudwatch_log_group.log_group.arn
}

output "log_group_arn" {
    value = aws_cloudwatch_log_group.log_group.arn
}
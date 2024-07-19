data "aws_sns_topic" "cloudwatch_alarms" {
  provider = aws.us-east-1

  name = "cloudwatch-alarms"
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_reached_ip_rate_limit" {
  provider = aws.us-east-1

  alarm_name        = "${var.environment}-reached-ip-rate-limit"
  alarm_description = "The number of blocked requests is greater than 1 in a 5-min window. Check Splunk to find the attacking IP and add it to the blocked list"

  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  period              = 300
  evaluation_periods  = 1

  namespace   = "AWS/WAFV2"
  metric_name = "BlockedRequests"
  statistic   = "Sum"

  dimensions = {
    WebACL = "cloudfront_waf_${var.environment}"
    Rule   = "OriginIPRateLimit"
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [data.aws_sns_topic.cloudwatch_alarms.arn]

  depends_on = [data.aws_sns_topic.cloudwatch_alarms]
}
resource "aws_cloudwatch_metric_alarm" "cloudfront_reached_ip_rate_limit" {
  provider = aws.us-east-1

  alarm_name        = "${var.environment}-reached-ip-rate-limit"
  alarm_description = "The number of blocked requests is greater than 1 in a 5-min window. [Check the Splunk report](https://gds.splunkcloud.com/en-GB/app/gds-543-forms/report?s=%2FservicesNS%2Fnobody%2Fgds-543-forms%2Fsaved%2Fsearches%2FBlocks%2520from%2520AWS%2520WAF&sid=_Y2F0YWxpbmEuZ2FyY2lhQGRpZ2l0YWwuY2FiaW5ldC1vZmZpY2UuZ292LnVr_Y2F0YWxpbmEuZ2FyY2lhQGRpZ2l0YWwuY2FiaW5ldC1vZmZpY2UuZ292LnVr_Z2RzLTU0My1mb3Jtcw__RMD5fc9d53b739302fc6_at_1729692555_82682&display.page.search.mode=verbose&dispatch.sample_ratio=1&earliest=-7d%40h&latest=now) to find the attacking IP and add it to the blocked list (ips_to_block) if we are concerned."

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
  alarm_actions      = [var.zendesk_alert_topics.us_east_1]
}
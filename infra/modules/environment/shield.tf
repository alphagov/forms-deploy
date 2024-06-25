removed {
  from = aws_shield_protection.cloudfront
  lifecycle { destroy = false }
}
removed {
  from = aws_shield_protection.alb
  lifecycle { destroy = false }
}
removed {
  from = aws_shield_application_layer_automatic_response.cloudfront
  lifecycle { destroy = false }
}
removed {
  from = aws_iam_role.shield_response_team
  lifecycle { destroy = false }
}
removed {
  from = aws_iam_role_policy_attachment.shield_response_team
  lifecycle { destroy = false }
}
removed {
  from = aws_shield_drt_access_role_arn_association.shield_response_team
  lifecycle { destroy = false }
}
removed {
  from = aws_shield_drt_access_log_bucket_association.alb_log_access
  lifecycle { destroy = false }
}
removed {
  from = aws_iam_role_policy.alb_log_access
  lifecycle { destroy = false }
}
removed {
  from = aws_shield_protection_group.protected_resources
  lifecycle { destroy = false }
}
removed {
  from = aws_ssm_parameter.pagerduty_email
  lifecycle { destroy = false }
}
removed {
  from = aws_ssm_parameter.pagerduty_phone_number
  lifecycle { destroy = false }
}
removed {
  from = aws_shield_proactive_engagement.escalation_contacts
  lifecycle { destroy = false }
}
removed {
  from = aws_route53_health_check.api
  lifecycle { destroy = false }
}
removed {
  from = aws_route53_health_check.admin
  lifecycle { destroy = false }
}
removed {
  from = aws_route53_health_check.product_page
  lifecycle { destroy = false }
}
removed {
  from = aws_route53_health_check.runner
  lifecycle { destroy = false }
}
removed {
  from = aws_cloudwatch_metric_alarm.cloudfront_total_error_rate
  lifecycle { destroy = false }
}
removed {
  from = aws_route53_health_check.cloudfront_total_error_rate
  lifecycle { destroy = false }
}
removed {
  from = aws_cloudwatch_metric_alarm.ddos_detection
  lifecycle { destroy = false }
}
removed {
  from = aws_route53_health_check.ddos_detection
  lifecycle { destroy = false }
}
removed {
  from = aws_route53_health_check.healthy_hosts
  lifecycle { destroy = false }
}
removed {
  from = aws_route53_health_check.aggregated
  lifecycle { destroy = false }
}
removed {
  from = aws_shield_protection_health_check_association.system_health
  lifecycle { destroy = false }
}
removed {
  from = aws_iam_service_linked_role.shield
  lifecycle { destroy = false }
}

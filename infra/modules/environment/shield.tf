resource "aws_shield_protection" "cloudfront" {
  name         = "cloudfront"
  resource_arn = module.cloudfront[0].cloudfront_arn
}

resource "aws_shield_protection" "alb" {
  name         = "${aws_lb.alb.name}-alb"
  resource_arn = aws_lb.alb.arn
}

resource "aws_shield_application_layer_automatic_response" "cloudfront" {
  resource_arn = module.cloudfront[0].cloudfront_arn
  action       = "BLOCK"

  depends_on = [aws_shield_protection.cloudfront]
}

resource "aws_iam_role" "shield_response_team" {
  name               = "shield-response-team"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        "Sid" : "ShieldResponseTeamAssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "drt.shield.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "shield_response_team" {
  role       = aws_iam_role.shield_response_team.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSShieldDRTAccessPolicy"
}

resource "aws_shield_drt_access_role_arn_association" "shield_response_team" {
  role_arn = aws_iam_role.shield_response_team.arn
}

resource "aws_shield_drt_access_log_bucket_association" "alb_log_access" {
  log_bucket              = module.logs_bucket.name
  role_arn_association_id = aws_shield_drt_access_role_arn_association.shield_response_team.id

  depends_on = [module.s3_log_shipping]
}

resource "aws_iam_role_policy" "alb_log_access" {
  name = "shield_response_team_alb_log_access"
  role = aws_iam_role.shield_response_team.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${module.logs_bucket.name}",
          "arn:aws:s3:::${module.logs_bucket.name}/*"
        ],
        Sid = "AWSDDoSResponseTeamAccessS3Bucket"
      }
    ]
  })
}

resource "aws_shield_protection_group" "protected_resources" {
  depends_on = [aws_shield_protection.alb, aws_shield_protection.cloudfront]

  protection_group_id = "Incoming-Traffic-Resources"
  aggregation         = "MAX"
  pattern             = "ARBITRARY"
  members             = [
    module.cloudfront[0].cloudfront_arn,
    aws_lb.alb.arn
  ]
}

data "aws_ssm_parameter" "contact_phone" {
  name = "/account/contact-phone-number"
}

data "aws_ssm_parameter" "contact_email" {
  name = "/account/contact-email"
}

resource "aws_shield_proactive_engagement" "escalation_contacts" {
  enabled = true

  emergency_contact {
    contact_notes = "GOV.UK Forms Infrastructure Team"
    email_address = data.aws_ssm_parameter.contact_email.value
    phone_number  = data.aws_ssm_parameter.contact_phone.value
  }

  depends_on = [aws_shield_drt_access_role_arn_association.shield_response_team]
}

resource "aws_route53_health_check" "api" {
  failure_threshold = "3"
  fqdn              = "api.${lookup(local.domain_names, var.env_name)}forms.service.gov.uk"
  port              = 443
  request_interval  = "30"
  resource_path     = "/ping"
  search_string     = "PONG"
  type              = "HTTPS_STR_MATCH"
}

resource "aws_route53_health_check" "admin" {
  failure_threshold = "3"
  fqdn              = "admin.${lookup(local.domain_names, var.env_name)}forms.service.gov.uk"
  port              = 443
  request_interval  = "30"
  resource_path     = "/ping"
  search_string     = "PONG"
  type              = "HTTPS_STR_MATCH"
}

resource "aws_route53_health_check" "product_page" {
  failure_threshold = "3"
  fqdn              = "product-page.${lookup(local.domain_names, var.env_name)}forms.service.gov.uk"
  port              = 443
  request_interval  = "30"
  resource_path     = "/ping"
  search_string     = "PONG"
  type              = "HTTPS_STR_MATCH"
}

resource "aws_route53_health_check" "runner" {
  failure_threshold = "3"
  fqdn              = "submit.${lookup(local.domain_names, var.env_name)}forms.service.gov.uk"
  port              = 443
  request_interval  = "30"
  resource_path     = "/ping"
  search_string     = "PONG"
  type              = "HTTPS_STR_MATCH"
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_total_error_rate" {
  #checkov:skip=CKV2_FORMS_AWS_1: Not alerting for now because of inter-region complexity, alarm is for Shield Team
  #checkov:skip=CKV_AWS_319: Not alerting for now because of inter-region complexity, alarm is for Shield Team

  provider            = aws.us-east-1
  alarm_name          = "${var.env_name}_cloudfront_total_error_rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "TotalErrorRate"
  namespace           = "AWS/Cloudfront"
  period              = 60
  statistic           = "Average"
  threshold           = 100
  treat_missing_data  = "notBreaching"
  actions_enabled     = false

  dimensions = {
    DistributionId = module.cloudfront[0].cloudfront_distribution_id
  }
}

resource "aws_route53_health_check" "cloudfront_total_error_rate" {
  type                            = "CLOUDWATCH_METRIC"
  cloudwatch_alarm_name           = aws_cloudwatch_metric_alarm.cloudfront_total_error_rate.alarm_name
  cloudwatch_alarm_region         = "us-east-1"
  insufficient_data_health_status = "Healthy"
}

resource "aws_cloudwatch_metric_alarm" "ddos_detection" {
  #checkov:skip=CKV2_FORMS_AWS_1: Not alerting for now because of inter-region complexity, alarm is for Shield Team
  #checkov:skip=CKV_AWS_319: Not alerting for now because of inter-region complexity, alarm is for Shield Team

  provider            = aws.us-east-1
  alarm_name          = "ddos_detected_in_${var.env_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DDoSDetected"
  namespace           = "AWS/DDoSProtection"
  period              = 300
  statistic           = "Sum"
  threshold           = 0

  actions_enabled = false
}

resource "aws_route53_health_check" "ddos_detection" {
  type                            = "CLOUDWATCH_METRIC"
  cloudwatch_alarm_name           = aws_cloudwatch_metric_alarm.ddos_detection.alarm_name
  cloudwatch_alarm_region         = "us-east-1"
  insufficient_data_health_status = "Healthy"
}

locals {
  apps = ["forms-admin", "forms-api", "forms-runner", "forms-product-page"]
}

data "aws_lb_target_group" "target_groups" {
  for_each = toset(local.apps)
  name     = "${each.key}-${var.env_name}"
}

resource "aws_route53_health_check" "healthy_hosts" {
  for_each = data.aws_lb_target_group.target_groups

  type                            = "CLOUDWATCH_METRIC"
  cloudwatch_alarm_name           = "alb_healthy_host_count_${each.value.name}"
  cloudwatch_alarm_region         = "eu-west-2"
  insufficient_data_health_status = "Healthy"
}

resource "aws_route53_health_check" "aggregated" {
  type                   = "CALCULATED"
  child_health_threshold = 1
  child_healthchecks     = concat([
    aws_route53_health_check.api.id,
    aws_route53_health_check.admin.id,
    aws_route53_health_check.product_page.id,
    aws_route53_health_check.runner.id,
    aws_route53_health_check.cloudfront_total_error_rate.id,
    aws_route53_health_check.ddos_detection.id
  ], [for _, alarm in aws_route53_health_check.healthy_hosts : alarm.id])
}

resource "aws_shield_protection_health_check_association" "system_health" {
  health_check_arn     = aws_route53_health_check.aggregated.arn
  shield_protection_id = aws_shield_protection.cloudfront.id
}
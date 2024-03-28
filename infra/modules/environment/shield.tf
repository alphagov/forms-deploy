resource "aws_shield_protection" "cloudfront" {
  name         = "shield-for-cloudfront"
  resource_arn = module.cloudfront[0].cloudfront_arn
}

resource "aws_shield_protection" "alb" {
  name         = "shield-for-${aws_lb.alb.name}"
  resource_arn = aws_lb.alb.arn
}

resource "aws_shield_application_layer_automatic_response" "cloudfront" {
  resource_arn = module.cloudfront[0].cloudfront_arn
  action       = "BLOCK"
}

//TODO: Review naming
resource "aws_iam_role" "shield_response_team" {
  name               = var.aws_shield_drt_access_role_arn
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        "Sid" : "",
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

resource "aws_shield_drt_access_log_bucket_association" "access_alb_logs" {
  log_bucket              = module.logs_bucket.name
  role_arn_association_id = aws_shield_drt_access_role_arn_association.shield_response_team.id
}

resource "aws_iam_role_policy" "access_alb_logs" {
  name = "shield_response_team_access_alb_logs"
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
    // TODO is this the correct way to reference our CloudFront distribution
    module.cloudfront[0].cloudfront_arn,
    aws_lb.alb.arn
  ]
}

//TODO: Review contact details retrieval
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

  emergency_contact {
    contact_notes = "GOV.UK Forms Infrastructure Team"
    email_address = data.aws_ssm_parameter.contact_email.value
    phone_number  = data.aws_ssm_parameter.contact_phone.value
  }

  depends_on = [aws_shield_drt_access_role_arn_association.shield_response_team]
}
resource "aws_shield_protection_health_check_association" "https_healthy_host" {
  health_check_arn     = aws_route53_health_check.https_healthy_host.arn
  shield_protection_id = aws_shield_protection.cloudfront.id
}

resource "aws_route53_health_check" "https_healthy_host" {
  type                   = "CALCULATED"
  child_health_threshold = 1
  child_healthchecks     = [
    aws_route53_health_check.api.id,
    aws_route53_health_check.admin.id,
    aws_route53_health_check.product_page.id,
    aws_route53_health_check.runner.id,
  ]
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
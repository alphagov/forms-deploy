resource "aws_shield_protection" "shield_for_cloudfront" {
  name         = "shield-for-cloudfront"
  resource_arn = module.cloudfront[0].cloudfront_arn
}

resource "aws_shield_protection" "shield_for_alb" {
  name         = "shield-for-${aws_lb.alb.name}"
  resource_arn = aws_lb.alb.arn
}

resource "aws_shield_application_layer_automatic_response" "cloudfront" {
  resource_arn = module.cloudfront[0].cloudfront_arn
  action       = "BLOCK"
}

resource "aws_iam_role" "ddos_response_team" {
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

resource "aws_iam_role_policy_attachment" "ddos_response_team" {
  role       = aws_iam_role.ddos_response_team.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSShieldDRTAccessPolicy"
}

resource "aws_shield_drt_access_role_arn_association" "ddos_response_team" {
  role_arn = aws_iam_role.ddos_response_team.arn
}

resource "aws_shield_drt_access_log_bucket_association" "drt_access_alb_logs" {
  log_bucket              = module.logs_bucket.name
  role_arn_association_id = aws_shield_drt_access_role_arn_association.ddos_response_team.id
}

resource "aws_iam_role_policy" "drt_access_alb_logs" {
  name = "ddos_response_team_access_alb_logs"
  role = aws_iam_role.ddos_response_team.id

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
  depends_on = [aws_shield_protection.shield_for_alb, aws_shield_protection.shield_for_cloudfront]

  protection_group_id = "Incoming-Traffic-Resources"
  aggregation = "MAX"
  pattern             = "ARBITRARY"
  members             = [
    module.cloudfront[0].cloudfront_arn,
    aws_lb.alb.arn
  ]
}

data "aws_ssm_parameter" "contact_phone_number" {
  name = "/account/contact-phone-number"
}

data "aws_ssm_parameter" "contact_email" {
  name = "/account/contact-email"
}

resource "aws_shield_proactive_engagement" "drt_escalation_contacts" {
  enabled = true

  emergency_contact {
    contact_notes = "GOV.UK Forms Infrastructure Team"
    email_address = data.aws_ssm_parameter.contact_email.value
    phone_number  = data.aws_ssm_parameter.contact_phone_number.value
  }

  emergency_contact {
    contact_notes = "GOV.UK Forms Infrastructure Team"
    email_address = data.aws_ssm_parameter.contact_email.value
    phone_number  = data.aws_ssm_parameter.contact_phone_number.value
  }

  depends_on = [aws_shield_drt_access_role_arn_association.ddos_response_team]
}


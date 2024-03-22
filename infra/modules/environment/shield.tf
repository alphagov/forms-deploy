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
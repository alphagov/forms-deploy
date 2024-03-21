locals {
  alb_certificate_sans = [
    "pipelines.tools.forms.service.gov.uk"
  ]
  #The AWS managed account for the ALB, see: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
  aws_lb_account_id = "652711504416"

}

data "aws_route53_zone" "tools_domain_zone" {
  name         = "tools.forms.service.gov.uk"
  private_zone = false
}

resource "aws_lb" "alb" {
  #checkov:skip=CKV_AWS_91:There's a ticket in the backlog to enable access logs
  name                       = "tools-forms-gov-uk"
  load_balancer_type         = "application"
  internal                   = false
  enable_deletion_protection = true
  drop_invalid_header_fields = true

  subnets         = [for s in aws_subnet.alb_subnets : s.id]
  security_groups = [aws_security_group.alb.id]

  access_logs {
    bucket  = module.logs_bucket.name
    prefix  = "deploy"
    enabled = true
  }
}

resource "aws_security_group" "alb" {
  name        = "alb-tools-forms-gov-uk"
  description = "Allows public inbound on 443 and outbound to VPC"
  vpc_id      = aws_vpc.tools.id

  ingress {
    description = "Port 443 from public"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Any port within VPC using TCP"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.tools.cidr_block]
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = module.acm_certicate_with_validation.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service unavailable"
      status_code  = 503
    }
  }
}

module "acm_certicate_with_validation" {
  source = "../../../modules/acm-cert-with-dns-validation"
  providers = {
    aws             = aws
    aws.certificate = aws # Create the certificate in the default eu-west-2
  }

  domain_name               = "tools.forms.service.gov.uk"
  subject_alternative_names = local.alb_certificate_sans
}

module "logs_bucket" {
  source = "../../../modules/secure-bucket"
  name   = "govuk-forms-alb-logs-deploy"

  extra_bucket_policies = [data.aws_iam_policy_document.allow_logs.json]
}

data "aws_iam_policy_document" "allow_logs" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.aws_lb_account_id}:root"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${module.logs_bucket.name}/deploy/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
  }
}

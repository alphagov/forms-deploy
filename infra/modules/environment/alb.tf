data "aws_caller_identity" "current" {}

locals {
  # domain_names and zone_names can be combined after the migration.
  # Used to lookup the domain name for the ALB record and certificate.
  domain_names = {
    user-research = "research.",
    dev           = "dev."
    staging       = "staging.",
    production    = ""
  }

  subject_alternative_names = {
    user-research = [
      "api.research.forms.service.gov.uk",
      "admin.research.forms.service.gov.uk",
      "submit.research.forms.service.gov.uk",
      "www.research.forms.service.gov.uk",
    ],
    dev = [
      "api.dev.forms.service.gov.uk",
      "admin.dev.forms.service.gov.uk",
      "submit.dev.forms.service.gov.uk",
      "www.dev.forms.service.gov.uk",
    ],
    staging = [
      "api.staging.forms.service.gov.uk",
      "admin.staging.forms.service.gov.uk",
      "submit.staging.forms.service.gov.uk",
      "www.staging.forms.service.gov.uk",
    ],
    production = [
      "api.forms.service.gov.uk",
      "admin.forms.service.gov.uk",
      "submit.forms.service.gov.uk",
      "www.forms.service.gov.uk",
    ]
  }

  account_id = data.aws_caller_identity.current.account_id

  #The AWS managed account for the ALB, see: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
  aws_lb_account_id = "652711504416"
}

# this is for csls log shipping
module "s3_log_shipping" {
  # Double slash afer .git in the module source below is required
  # https://developer.hashicorp.com/terraform/language/modules/sources#modules-in-package-sub-directories
  source                   = "git::https://github.com/alphagov/cyber-security-shared-terraform-modules.git//s3/s3_log_shipping?ref=6fecf620f987ba6456ea6d7307aed7d83f077c32"
  s3_processor_lambda_role = "arn:aws:iam::885513274347:role/csls_prodpython/csls_process_s3_logs_lambda_prodpython"
  s3_name                  = module.logs_bucket.name
}

module "logs_bucket" {
  source = "../secure-bucket"
  name   = "govuk-forms-alb-logs-${var.env_name}"

  extra_bucket_policies = [data.aws_iam_policy_document.allow_logs.json, module.s3_log_shipping.s3_policy]
}

data "aws_iam_policy_document" "allow_logs" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.aws_lb_account_id}:root"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${module.logs_bucket.name}/${var.env_name}/AWSLogs/${local.account_id}/*"]
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.logs_bucket.name
  queue {
    queue_arn = "arn:aws:sqs:eu-west-2:885513274347:cyber-security-s3-to-splunk-prodpython"
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lb" "alb" {
  #checkov:skip=CKV2_AWS_28:WAF is not considered necessary at this time.

  name                       = "forms-${var.env_name}"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = true
  drop_invalid_header_fields = true
  security_groups            = [aws_security_group.alb.id]
  subnets                    = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
    aws_subnet.public_c.id
  ]

  access_logs {
    bucket  = module.logs_bucket.name
    prefix  = var.env_name
    enabled = true
  }
}

resource "aws_security_group" "alb" {
  name        = "alb-${var.env_name}"
  description = "Allows public inbound on 443 and outbound to VPC"
  vpc_id      = aws_vpc.forms.id

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
    cidr_blocks = [aws_vpc.forms.cidr_block]
  }
}

module "acm_certicate_with_validation" {
  source    = "../acm-cert-with-dns-validation"
  providers = {
    aws             = aws
    aws.certificate = aws # Create the certificate in the default eu-west-2
  }

  domain_name               = "${lookup(local.domain_names, var.env_name)}forms.service.gov.uk"
  subject_alternative_names = lookup(local.subject_alternative_names, var.env_name)
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

resource "aws_wafv2_ip_set" "ips_to_block_alb" {
  name               = "${var.env_name}-ips-to-block-alb"
  description        = "Origin IPs to block for alb in ${var.env_name} environment"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = var.ips_to_block
}

resource "aws_wafv2_web_acl" "alb" {
  #checkov:skip=CKV_AWS_192:We don't use log4j
  #checkov:skip=CKV2_AWS_31:We cannot set it up without help from cyber. We're working on it

  name        = "alb_${var.env_name}"
  description = "AWS WAF for the load balancer"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "OriginIPBlock"
    sampled_requests_enabled   = false
  }

  rule {
    name     = "OriginIPBlock"
    priority = 110

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ips_to_block_alb.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.env_name}_ips_blocked_alb"
      sampled_requests_enabled   = false
    }

  }
}

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = aws_wafv2_web_acl.alb.arn
}

resource "aws_shield_protection" "shield_for_alb" {
  name         = "shield-for-${aws_lb.alb.name}"
  resource_arn = aws_lb.alb.arn
}
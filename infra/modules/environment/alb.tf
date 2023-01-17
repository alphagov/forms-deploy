locals {
  # domain_names and zone_names can be combined after the migration.
  # Used to lookup the domain name for the ALB record and certificate.
  domain_names = {
    user-research = "research.",
    dev           = "dev."
    staging       = "stage.",
    production    = "prod-temp." #TODO: Change to "" for migration
  }

  # Used for looking up the Route53 hosted zone to hold the ALB record
  zone_names = {
    user-research = "research.",
    dev           = "dev."
    staging       = "stage.",
    production    = ""
  }
}

resource "aws_lb" "alb" {
  #checkov:skip=CKV_AWS_91:ALB access logs to be added in https://trello.com/c/ArInd1jz/419-enable-alb-access-logs
  #checkov:skip=CKV2_AWS_28:WAF is not considered necessary at this time.

  name                       = "forms-${var.env_name}"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = true
  drop_invalid_header_fields = true
  security_groups            = [aws_security_group.alb.id]
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
    aws_subnet.public_c.id
  ]
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

resource "aws_acm_certificate" "alb_cert" {
  domain_name       = "${lookup(local.domain_names, var.env_name)}forms.service.gov.uk"
  validation_method = "DNS"

  subject_alternative_names = [
    "api.${lookup(local.domain_names, var.env_name)}forms.service.gov.uk",
    "admin.${lookup(local.domain_names, var.env_name)}forms.service.gov.uk",
    "submit.${lookup(local.domain_names, var.env_name)}forms.service.gov.uk",
    "www.${lookup(local.domain_names, var.env_name)}forms.service.gov.uk"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.alb_cert.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service unavailable"
      status_code  = 503
    }
  }
}


data "aws_route53_zone" "public" {
  name         = "${lookup(local.zone_names, var.env_name)}forms.service.gov.uk."
  private_zone = false
}

resource "aws_route53_record" "alb_a_record" {
  zone_id = data.aws_route53_zone.public.id
  name    = "*.${lookup(local.domain_names, var.env_name)}forms.service.gov.uk."
  type    = "CNAME"
  ttl     = 60
  records = [aws_lb.alb.dns_name]
}


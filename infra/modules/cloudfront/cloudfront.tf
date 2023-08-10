# The Certificate for CloudFront must be in us-east-1
module "acm_certificate_with_validation" {
  source = "../acm-cert-with-dns-validation"

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names

  providers = {
    aws             = aws
    aws.certificate = aws.us-east-1
  }
}

data "aws_cloudfront_response_headers_policy" "cors" {
  name = "Managed-SimpleCORS"
}

resource "aws_cloudfront_distribution" "main" {
  #checkov:skip=CKV_AWS_86:Access logging not necessary currently.
  #checkov:skip=CKV2_AWS_32:Checkov error, response headers policy is set.
  #checkov:skip=CKV2_AWS_47:We don't use log4j

  origin {
    domain_name = var.alb_dns_name
    origin_id   = "application_load_balancer"

    custom_origin_config {
      https_port             = 443
      http_port              = 80
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "application_load_balancer"

    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.cors.id

    forwarded_values {
      cookies {
        forward = "all"
      }
      headers      = ["*"]
      query_string = true
    }
  }

  is_ipv6_enabled     = true
  enabled             = true
  default_root_object = "/"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = module.acm_certificate_with_validation.arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method       = "sni-only"
  }

  aliases    = var.subject_alternative_names
  web_acl_id = aws_wafv2_web_acl.this.arn
}

resource "aws_wafv2_web_acl" "this" {
  #checkov:skip=CKV_AWS_192:We don't use log4j
  provider = aws.us-east-1

  name        = "cloudfront_waf_${var.env_name}"
  description = "AWS WAF for the CloudFront Distribution"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "OriginIPRateLimit"
    sampled_requests_enabled   = false
  }

  rule {
    name     = "OriginIPRateLimit"
    priority = 1

    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = var.ip_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "OriginIPRateLimit"
      sampled_requests_enabled   = false
    }
  }
}

resource "aws_cloudwatch_log_group" "waf" {
  #checkov:skip=CKV_AWS_158:Amazon managed SSE is sufficient.
  provider          = aws.us-east-1
  name              = "aws-waf-logs-${var.env_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_subscription_filter" "waf_csls_log_subscription" {
  provider        = aws.us-east-1
  name            = "waf_csls_log_subscription"
  log_group_name  = "aws-waf-logs-${var.env_name}"
  filter_pattern  = ""
  destination_arn = "arn:aws:logs:eu-west-2:885513274347:destination:csls_cw_logs_destination_prodpython"
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  provider                = aws.us-east-1
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
  resource_arn            = aws_wafv2_web_acl.this.arn

  logging_filter {
    default_behavior = "DROP"

    filter {
      behavior    = "KEEP"
      requirement = "MEETS_ANY"

      condition {
        action_condition {
          action = "BLOCK"
        }
      }
      condition {
        action_condition {
          action = "COUNT"
        }
      }
    }
  }
}

output "cloudfront_dns_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

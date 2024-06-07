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

data "aws_cloudfront_cache_policy" "caching_policy" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "origin_request_policy" {
  name = "Managed-CORS-S3Origin"
}

resource "aws_cloudfront_distribution" "main" {
  #checkov:skip=CKV_AWS_34:viewer_protocol_policy is already redirect-to-https
  #checkov:skip=CKV_AWS_86:Access logging not necessary currently.
  #checkov:skip=CKV2_AWS_32:Checkov error, response headers policy is set.
  #checkov:skip=CKV2_AWS_47:We don't use log4j
  #checkov:skip=CKV_AWS_310:We don't have a backup origin to fail over to

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

  origin {
    domain_name = module.error_page_bucket.website_url
    origin_id   = "error_page"

    custom_origin_config {
      https_port             = 443
      http_port              = 80
      origin_protocol_policy = "http-only"
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

  aliases    = concat([var.domain_name], var.subject_alternative_names)
  web_acl_id = aws_wafv2_web_acl.this.arn

  custom_error_response {
    error_code         = 504
    response_page_path = "/cloudfront/error_page.html"
    response_code      = 200
  }

  ordered_cache_behavior {
    path_pattern             = "/cloudfront/error_page.html"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "error_page"
    viewer_protocol_policy   = "allow-all"
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_policy.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.origin_request_policy.id
  }
}

resource "aws_wafv2_ip_set" "system_egress_ips" {
  provider = aws.us-east-1

  name               = "${var.env_name}-system-egress-ips"
  description        = "Egress IPs for ${var.env_name} environment"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"

  addresses = [for ip in var.nat_gateway_egress_ips : "${ip}/32"]
}

resource "aws_wafv2_ip_set" "ips_to_block" {
  provider = aws.us-east-1

  name               = "${var.env_name}-ips-to-block"
  description        = "Origin IPs to block for ${var.env_name} environment"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"

  addresses = var.ips_to_block
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

  lifecycle {
    create_before_destroy = true
  }

  rule {
    name     = "allow_egress_ips_of_${var.env_name}_env"
    priority = 10

    action {
      allow {}
      # Stop processing
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.system_egress_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.env_name}_env_system_ips_allowed"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "OriginIPRateLimit"
    priority = 100

    action {
      block {}
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

  rule {
    name     = "OriginIPBlock"
    priority = 110

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ips_to_block.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.env_name}_ips_blocked"
      sampled_requests_enabled   = false
    }

  }
}

resource "aws_cloudwatch_log_group" "waf" {
  #checkov:skip=CKV_AWS_338:We're happy with 30 days retention for now
  #checkov:skip=CKV_AWS_158:Amazon managed SSE is sufficient.
  provider          = aws.us-east-1
  name              = "aws-waf-logs-${var.env_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_subscription_filter" "waf_csls_log_subscription" {
  provider        = aws.us-east-1
  name            = "waf_csls_log_subscription"
  log_group_name  = "aws-waf-logs-${var.env_name}"
  filter_pattern  = ""
  destination_arn = "arn:aws:logs:us-east-1:885513274347:destination:csls_cw_logs_destination_prodpython"
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

resource "aws_cloudwatch_metric_alarm" "reached_ip_rate_limit" {
  provider = aws.us-east-1

  alarm_name        = "${var.env_name}-reached-ip-rate-limit"
  alarm_description = "The number of blocked requests is greater than 1 in a 5-min window. Check Splunk to find the attacking IP and add it to the blocked list"

  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  period              = 300
  evaluation_periods  = 1

  namespace   = "AWS/WAFV2"
  metric_name = "BlockedRequests"
  statistic   = "Sum"

  dimensions = {
    WebACL = "cloudfront_waf_${var.env_name}"
    Rule   = "OriginIPRateLimit"
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alarms.arn]

  depends_on = [aws_sns_topic.cloudwatch_alarms]
}

resource "aws_sns_topic" "cloudwatch_alarms" {
  #checkov:skip=CKV_AWS_26:We don't need this to be encrypted at the moment
  provider = aws.us-east-1
  name     = "cloudwatch-alarms"
}

resource "aws_sns_topic_subscription" "email" {
  provider  = aws.us-east-1
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_subscription_endpoint
}

output "cloudfront_dns_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.main.arn
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.main.id
}

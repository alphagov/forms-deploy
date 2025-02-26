resource "aws_wafv2_ip_set" "system_egress_ips" {
  provider = aws.us-east-1

  name               = "${var.environment_name}-system-egress-ips"
  description        = "Egress IPs for ${var.environment_name} environment"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"

  addresses = [for ip in var.nat_gateway_egress_ips : "${ip}/32"]
}

resource "aws_wafv2_ip_set" "ips_to_block" {
  provider = aws.us-east-1

  name               = "${var.environment_name}-ips-to-block"
  description        = "Origin IPs to block for ${var.environment_name} environment"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"

  addresses = var.ips_to_block
}

resource "aws_wafv2_web_acl" "this" {
  #checkov:skip=CKV_AWS_192:We don't use log4j
  provider = aws.us-east-1

  name        = "cloudfront_waf_${var.environment_name}"
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
    name     = "allow_egress_ips_of_${var.environment_name}_env"
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
      metric_name                = "${var.environment_name}_env_system_ips_allowed"
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

        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            allow {}
          }
        }
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
      metric_name                = "${var.environment_name}_ips_blocked"
      sampled_requests_enabled   = false
    }

  }
}

resource "aws_cloudwatch_log_group" "waf" {
  #checkov:skip=CKV_AWS_338:We're happy with 30 days retention for now
  #checkov:skip=CKV_AWS_158:Amazon managed SSE is sufficient.
  provider          = aws.us-east-1
  name              = "aws-waf-logs-${var.environment_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_subscription_filter" "waf_csls_log_subscription" {
  count = var.send_logs_to_cyber ? 1 : 0

  provider        = aws.us-east-1
  name            = "waf_csls_log_subscription"
  log_group_name  = "aws-waf-logs-${var.environment_name}"
  filter_pattern  = ""
  destination_arn = "arn:aws:logs:us-east-1:885513274347:destination:csls_cw_logs_destination_prodpython"
}

moved {
  from = aws_cloudwatch_log_subscription_filter.waf_csls_log_subscription
  to   = aws_cloudwatch_log_subscription_filter.waf_csls_log_subscription[0]
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

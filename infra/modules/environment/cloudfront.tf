# The Certificate for CloudFront must be in us-east-1
resource "aws_acm_certificate" "cloud_front" {
  provider = aws.us-east-1

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

data "aws_route53_zone" "public" {
  name         = "${lookup(local.zone_names, var.env_name)}forms.service.gov.uk."
  private_zone = false
}

resource "aws_route53_record" "cloud_front_cname" {
  zone_id = data.aws_route53_zone.public.id
  name    = "*.${lookup(local.domain_names, var.env_name)}forms.service.gov.uk."
  type    = "CNAME"
  ttl     = 60
  records = [aws_cloudfront_distribution.main.domain_name]
}

data "aws_cloudfront_response_headers_policy" "cors" {
  name = "Managed-SimpleCORS"
}

resource "aws_cloudfront_distribution" "main" {
  #checkov:skip=CKV_AWS_86:Access logging not necessary currently.
  #checkov:skip=CKV_AWS_68:WAF is not necessary currently.
  #checkov:skip=CKV2_AWS_47:WAF is not necessary currently.
  #checkov:skip=CKV2_AWS_32:Checkov error, response headers policy is set.
  origin {
    domain_name = aws_lb.alb.dns_name
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
    acm_certificate_arn      = aws_acm_certificate.cloud_front.arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method       = "sni-only"
  }

  aliases = [
    "api.${lookup(local.domain_names, var.env_name)}forms.service.gov.uk",
    "admin.${lookup(local.domain_names, var.env_name)}forms.service.gov.uk",
    "submit.${lookup(local.domain_names, var.env_name)}forms.service.gov.uk",
    "www.${lookup(local.domain_names, var.env_name)}forms.service.gov.uk"
  ]
}

output "cloudfront_dns_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

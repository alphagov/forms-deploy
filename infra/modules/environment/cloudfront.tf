module "cloudfront" {
  count  = var.enable_cloudfront ? 1 : 0
  source = "../cloudfront"
  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1 # Create the certificate in us-east-1 for CloudFront
  }

  env_name      = var.env_name
  domain_name   = "${lookup(local.domain_names, var.env_name)}forms.service.gov.uk"
  alb_dns_name  = aws_lb.alb.dns_name
  ip_rate_limit = var.ip_rate_limit

  subject_alternative_names = lookup(local.subject_alternative_names, var.env_name)
}

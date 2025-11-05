module "cloudfront" {
  source = "../../../modules/cloudfront"

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1 # Create the certificate in us-east-1 for CloudFront
  }


  alb_dns_name = module.alb.alb_dns_name
  domain_name  = "review.forms.service.gov.uk"
  subject_alternative_names = [
    "*.admin.review.forms.service.gov.uk",
    "*.submit.review.forms.service.gov.uk",
    "*.www.review.forms.service.gov.uk",
  ]
  env_name                      = "review"
  nat_gateway_egress_ips        = module.vpc.nat_gateway_egress_ips
  send_logs_to_cyber            = var.send_logs_to_cyber
  kinesis_subscription_role_arn = data.terraform_remote_state.account.outputs.kinesis_subscription_role_arn
}

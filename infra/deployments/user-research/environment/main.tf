module "environment" {
  source   = "../../../modules/environment"
  env_name = "user-research"

  manage_certificate_dns_validation = true

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}


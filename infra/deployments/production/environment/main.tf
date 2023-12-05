module "environment" {
  source   = "../../../modules/environment"
  env_name = "production"

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  ips_to_block = []
}


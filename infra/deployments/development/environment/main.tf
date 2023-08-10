module "environment" {
  source   = "../../../modules/environment"
  env_name = "dev"

  enable_cloudfront = true

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}


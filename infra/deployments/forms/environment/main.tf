module "environment" {
  source   = "../../../modules/environment"
  env_name = var.environment_name

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}


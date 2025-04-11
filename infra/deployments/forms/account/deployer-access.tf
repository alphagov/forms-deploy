module "deployer_access" {
  source                  = "../../../modules/deployer-access"
  environment_name        = var.environment_name
  environment_type        = replace(var.environment_type, "_", "-") # The user research account uses an underscore for environment type and a dash for environment name
  account_id              = var.aws_account_id
  deploy_account_id       = var.deploy_account_id
  hosted_zone_id          = aws_route53_zone.public.id
  codestar_connection_arn = var.codestar_connection_arn

  depends_on = [aws_route53_zone.public]
}


module "deployer_access" {
  source                  = "../../modules/deployer-access"
  env_name                = var.environment_name
  hosted_zone_id          = aws_route53_zone.public.id
  codestar_connection_arn = var.codestar_connection_arn

  depends_on = [aws_route53_zone.public]
}


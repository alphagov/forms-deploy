module "deployer_access" {
  source                              = "../../modules/deployer-access"
  env_name                            = var.environment_name
  hosted_zone_id                      = aws_route53_zone.public.id
  codestar_connection_arn             = var.codestar_connection_arn
  dynamodb_state_file_locks_table_arn = "arn:aws:dynamodb:eu-west-2:${var.aws_account_id}:table/govuk-forms-${var.environment_type}-tfstate-locking"

  depends_on = [aws_route53_zone.public]
}


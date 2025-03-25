locals {
  # The user research account uses an underscore for environment type
  # and a dash for environment name. This is a bug fix to get the user-research
  # account Terraform working again while we determine what impact changing
  # the values will have.
  dynamodb_table_name = (var.environment_type == "user_research" ?
    "govuk-forms-user-research-tfstate-locking" :
  "govuk-forms-${var.environment_type}-tfstate-locking")
}
module "deployer_access" {
  source                              = "../../../modules/deployer-access"
  environment_name                    = var.environment_name
  environment_type                    = replace(var.environment_type, "_", "-") # See comment about dynamodb table name
  account_id                          = var.aws_account_id
  deploy_account_id                   = var.deploy_account_id
  hosted_zone_id                      = aws_route53_zone.public.id
  codestar_connection_arn             = var.codestar_connection_arn
  dynamodb_state_file_locks_table_arn = "arn:aws:dynamodb:eu-west-2:${var.aws_account_id}:table/*"

  depends_on = [aws_route53_zone.public]
}


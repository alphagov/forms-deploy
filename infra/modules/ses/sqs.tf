module "sqs" {
  source           = "./sqs"
  environment_type = var.environment_type
  account_id       = local.account_id
}

# module "forms_runner_sqs" {
#   source           = "./sqs"
#   environment_type = var.environment_type
#   account_id       = local.account_id
# }

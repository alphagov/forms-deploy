module "all_accounts" {
  source = "../../../modules/all-accounts"
}

locals {
  # Map environment types to their AWS account IDs
  environment_type_to_account_id = {
    development   = module.all_accounts.environment_accounts_id["development"]
    staging       = module.all_accounts.environment_accounts_id["staging"]
    production    = module.all_accounts.environment_accounts_id["production"]
    user-research = module.all_accounts.environment_accounts_id["user-research"]
  }

  # Map environment types to their actual environment names used in role ARNs
  environment_type_to_name = {
    development   = "dev"
    staging       = "staging"
    production    = "production"
    user-research = "user-research"
  }
}

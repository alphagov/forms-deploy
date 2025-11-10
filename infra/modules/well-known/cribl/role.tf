locals {
  cribl_role_name = "cribl-ingest"
  cribl_role_arn  = "arn:aws:iam::${module.all_accounts.deploy_account_id}:role/${local.cribl_role_name}"
}

output "cribl_role_name" {
  value = local.cribl_role_name
}
output "cribl_role_arn" {
  value = local.cribl_role_arn
}

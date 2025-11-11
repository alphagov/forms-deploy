module "log_to_splunk" {
  #checkov:skip=CKV_AWS_111:KMS key policies use resources=["*"] as they are scoped to the specific key when attached
  #checkov:skip=CKV_AWS_356:KMS key policies use resources=["*"] as they are scoped to the specific key when attached
  #checkov:skip=CKV_AWS_109:KMS key policies use resources=["*"] as they are scoped to the specific key when attached
  source = "./log_to_splunk"

  providers = {
    aws.us-east-1 = aws.us-east-1
  }

  cribl_worker_arn    = "arn:aws:iam::195936642447:role/main-gds-general"
  account_access_arns = local.all_account_arns
  aws_account_sources = local.all_account_ids
}

locals {
  all_account_arns = flatten([[for _, account_number in module.other_accounts.all_accounts_id :
    [
      "arn:aws:logs:eu-west-2:${account_number}:*",
      "arn:aws:logs:us-east-1:${account_number}:*",
    ]
  ]])

  all_account_ids = [for _, account_number in module.other_accounts.all_accounts_id : account_number]
}

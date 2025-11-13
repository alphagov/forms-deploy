locals {
  cribl_sqs_queue_name = "cribl-s3-events"
  cribl_sqs_queue_arn  = "arn:aws:sqs:eu-west-2:${module.all_accounts.deploy_account_id}:${local.cribl_sqs_queue_name}"
}
output "cribl_sqs_queue_name" {
  value = local.cribl_sqs_queue_name
}
output "cribl_sqs_queue_arn" {
  value = local.cribl_sqs_queue_arn
}

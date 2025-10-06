locals {
  s3_logs_processor_role_arn = "arn:aws:iam::885513274347:role/csls_prodpython/csls_process_s3_logs_lambda_prodpython"
  s3_to_splunk_queue_arn     = "arn:aws:sqs:eu-west-2:885513274347:cyber-security-s3-to-splunk-prodpython"
}

module "s3_log_shipping" {
  # Double slash after .git in the module source below is required
  # https://developer.hashicorp.com/terraform/language/modules/sources#modules-in-package-sub-directories
  source                   = "git::https://github.com/alphagov/cyber-security-shared-terraform-modules.git//s3/s3_log_shipping?ref=6fecf620f987ba6456ea6d7307aed7d83f077c32"
  s3_processor_lambda_role = local.s3_logs_processor_role_arn
  s3_name                  = var.s3_name
}
moved {
  from = aws_s3_bucket_ownership_controls.transfer_object_ownership
  to   = module.s3_log_shipping.aws_s3_bucket_ownership_controls.transfer_object_ownership
}

resource "aws_s3_bucket_notification" "s3_bucket_notification" {
  count  = var.enable_bucket_notification ? 1 : 0
  bucket = var.s3_name
  queue {
    queue_arn = local.s3_to_splunk_queue_arn
    events    = ["s3:ObjectCreated:*"]
  }
}

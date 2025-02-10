module "sqs" {
  source           = "./sqs"
  environment_type = var.environment_type
  account_id       = local.account_id
  identifier       = "ses"
  policy_id        = "SESBouncesComplaintsQueueTopic"
}

module "auth0_sqs" {
  source           = "./sqs"
  environment_type = var.environment_type
  account_id       = local.account_id
  identifier       = "ses"
  policy_id        = "SESBouncesComplaintsQueueTopic"
}

module "submission_email_sqs" {
  source           = "./sqs"
  environment_type = var.environment_type
  account_id       = local.account_id
  identifier       = "submission_email_ses"
  policy_id        = "SubmissionEmailSESBouncesComplaintsQueueTopic"
}
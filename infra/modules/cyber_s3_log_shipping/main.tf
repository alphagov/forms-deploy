# S3 bucket notifications for both CSLS and Cribl

locals {
  enable_cribl = var.destination == "cribl"
  enable_csls  = var.destination == "csls"
}

resource "aws_s3_bucket_notification" "s3_bucket_notification" {
  bucket = var.s3_name

  # We can't push events to multiple SQS queues at once, so we conditionally choose
  # which queue to use based on the destination variable.
  queue {
    queue_arn = local.enable_cribl ? module.cribl_well_known[0].cribl_sqs_queue_arn : module.csls_well_known.s3_to_splunk_queue_arn
    events    = ["s3:ObjectCreated:*"]
  }
}

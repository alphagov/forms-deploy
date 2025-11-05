# S3 bucket notifications for both CSLS and Cribl

resource "aws_s3_bucket_notification" "s3_bucket_notification" {
  count  = var.enable_bucket_notification ? 1 : 0
  bucket = var.s3_name

  # CSLS notification
  queue {
    queue_arn = local.s3_to_splunk_queue_arn
    events    = ["s3:ObjectCreated:*"]
  }

  # Cribl notification
  dynamic "queue" {
    for_each = var.enable_cribl ? [1] : []
    content {
      queue_arn = module.cribl_well_known[each.key].cribl_sqs_queue_arn
      events    = ["s3:ObjectCreated:*"]
    }
  }
}

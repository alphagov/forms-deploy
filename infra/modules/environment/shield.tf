module "shield" {
  count  = var.enable_shield_advanced ? 1 : 0
  source = "../shield"

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  env_name = var.env_name

  cloudfront_arn             = module.cloudfront[0].cloudfront_arn
  cloudfront_distribution_id = module.cloudfront[0].cloudfront_distribution_id

  alb_name            = aws_lb.alb.name
  alb_arn             = aws_lb.alb.arn
  alb_log_bucket_name = module.logs_bucket.name

  # Required to prevent OptimisticLockException error (lock contention exists with Shield DRT Log Bucket Association)
  depends_on = [module.s3_log_shipping]
}
# Hosts the tail-sampling policy Alloy pulls live via import.http
# (docker/alloy/config.alloy) - lets the sampling ratio/latency threshold be
# tuned by editing alloy-remote-config/tail-sampling.alloy and running
# terraform apply, rather than rebuilding the alloy image and redeploying
# the ECS service (neither is touched by this). Alloy polls every 30s and
# hot-reloads automatically.
module "alloy_remote_config" {
  source = "../secure-bucket"

  name                   = "forms-tempo-alloy-remote-config-${var.env_name}"
  access_logging_enabled = false
  extra_bucket_policies  = [data.aws_iam_policy_document.alloy_remote_config_access.json]
}

# The tracked source of truth for the object Alloy fetches - kept out of
# docker/alloy since it's never built into that image, uploaded here rather
# than by hand so a content change shows up in `terraform plan` like
# everything else in this repo, and so there's no separate manual step to
# forget.
resource "aws_s3_object" "tail_sampling_config" {
  bucket = module.alloy_remote_config.name
  key    = "tail-sampling.alloy"
  source = "${path.module}/alloy-remote-config/tail-sampling.alloy"
  etag   = filemd5("${path.module}/alloy-remote-config/tail-sampling.alloy")
}

# Anonymous (unsigned) GET, scoped to requests originating from this VPC.
# import.http has no SigV4 signing support, so IAM-role-based access (the
# pattern tempo/mimir use for their own S3 access in s3.tf) doesn't work
# here - Alloy just does a plain HTTPS GET. Scoping the "*" principal to
# aws:SourceVpc is what keeps this from being genuinely public: S3's
# block_public_policy (enabled by secure-bucket) recognises a
# network-restricting condition like this as non-public, so it's allowed
# despite the wildcard principal.
data "aws_iam_policy_document" "alloy_remote_config_access" {
  statement {
    sid    = "AllowGetFromVpcOnly"
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${module.alloy_remote_config.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpc"
      values   = [var.vpc_id]
    }
  }
}

locals {
  # Virtual-hosted-style URL - eu-west-2 hardcoded to match this module's
  # existing convention (see e.g. alloy.tf's awslogs-region) rather than
  # adding a data.aws_region source for one string.
  alloy_remote_config_url = "https://${module.alloy_remote_config.name}.s3.eu-west-2.amazonaws.com/tail-sampling.alloy"
}

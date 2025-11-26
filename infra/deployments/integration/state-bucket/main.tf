terraform {
  backend "s3" {
    key = "state-bucket.tfstate"
  }
}

variable "bucket_name" {
  type        = string
  description = "The name to give to the S3 bucket. Standard S3 bucket naming rules apply."
}

module "state_bucket" {
  source = "../../../modules/state-bucket"

  bucket_name            = var.bucket_name
  access_logging_enabled = true
}


output "bucket_name" {
  value = module.state_bucket.bucket_name
}

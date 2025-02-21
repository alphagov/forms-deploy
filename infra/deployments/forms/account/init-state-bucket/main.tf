terraform {
  backend "local" {
    path = "state-bucket.tfstate"
  }
}

variable "bucket_name" {
  type        = string
  description = "The name to give to the S3 bucket. Standard S3 bucket naming rules apply."
}

variable "dynamodb_table" {
  type        = string
  description = "The name to give to the DynamoDB table that will be used for state file locking."
}

module "state_bucket" {
  source = "../../../../modules/state-bucket"

  bucket_name = var.bucket_name
}

resource "aws_dynamodb_table" "state_locking_table" {
  #checkov:skip=CKV_AWS_28:we don't need point in time recovery on this table
  #checkov:skip=CKV_AWS_119:we don't require encryption on this table
  name         = var.dynamodb_table
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "bucket_name" {
  value = module.state_bucket.bucket_name
}

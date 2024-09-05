data "terraform_remote_state" "redis" {
  backend = "s3"

  config = {
    key            = "redis.tfstate"
    bucket         = var.bucket
    region         = "eu-west-2"
    dynamodb_table = var.dynamodb_table
  }
}
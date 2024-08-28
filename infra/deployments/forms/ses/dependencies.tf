data "terraform_remote_state" "account" {
  backend = "s3"

  config = {
    key            = "account.tfstate"
    bucket         = var.bucket
    region         = "eu-west-2"
    dynamodb_table = var.dynamodb_table
  }
}
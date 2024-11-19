data "terraform_remote_state" "deploy_ecr" {
  backend = "s3"

  config = {
    key            = "ecr.tfstate"
    bucket         = var.bucket
    region         = "eu-west-2"
    dynamodb_table = var.dynamodb_table
  }
}

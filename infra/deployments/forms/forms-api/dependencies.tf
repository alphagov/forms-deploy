data "terraform_remote_state" "forms_environment" {
  backend = "s3"

  config = {
    key          = "network.tfstate"
    bucket       = var.bucket
    region       = "eu-west-2"
    use_lockfile = var.dynamodb_table
  }
}
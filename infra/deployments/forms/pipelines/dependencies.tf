data "terraform_remote_state" "forms_environment" {
  backend = "s3"

  config = {
    key            = "network.tfstate"
    bucket         = var.bucket
    region         = "eu-west-2"
    dynamodb_table = var.dynamodb_table
  }
}

data "terraform_remote_state" "forms_admin" {
  backend = "s3"

  config = {
    key            = "forms_admin.tfstate"
    bucket         = var.bucket
    region         = "eu-west-2"
    dynamodb_table = var.dynamodb_table
  }
}

data "terraform_remote_state" "forms_api" {
  backend = "s3"

  config = {
    key            = "forms_api.tfstate"
    bucket         = var.bucket
    region         = "eu-west-2"
    dynamodb_table = var.dynamodb_table
  }
}

data "terraform_remote_state" "forms_runner" {
  backend = "s3"

  config = {
    key            = "forms_runner.tfstate"
    bucket         = var.bucket
    region         = "eu-west-2"
    dynamodb_table = var.dynamodb_table
  }
}

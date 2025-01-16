terraform {
  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-integration-tfstate"
    key    = "review.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = [var.aws_account_id]
  default_tags {
    tags = {
      Environment = "review"
      Deployment  = "integration/review"
    }
  }
}

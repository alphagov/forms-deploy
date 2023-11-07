terraform {
  backend "s3" {
    bucket = "gds-forms-user-research-tfstate"
    key    = "redis.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["619109835131"]

  default_tags {
    tags = {
      Environment = "user-research"
      Deployment  = "user-research/redis"
    }
  }
}



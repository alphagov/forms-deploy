terraform {
  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-development-tfstate"
    key    = "forms_product_page.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["498160065950"]

  default_tags {
    tags = {
      Environment = "development"
      Deployment  = "development/forms-product-page"
    }
  }
}



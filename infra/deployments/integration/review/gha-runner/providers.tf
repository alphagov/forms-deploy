## This is needed to enable us to use AWS provider functions in the module
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

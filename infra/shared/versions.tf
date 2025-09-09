terraform {
  required_version = "1.13.2"
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "2.7.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "6.12.0"
    }
    auth0 = {
      source  = "auth0/auth0"
      version = "1.7.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

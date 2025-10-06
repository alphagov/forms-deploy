terraform {
  required_version = "1.13.2"
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "2.7.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "6.15.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "1.58.0"
    }
    auth0 = {
      source  = "auth0/auth0"
      version = "1.31.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
}

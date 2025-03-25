data "terraform_remote_state" "redis" {
  backend = "s3"

  config = {
    key    = "redis.tfstate"
    bucket = var.bucket
    region = "eu-west-2"

    use_lockfile = true
  }
}

data "terraform_remote_state" "forms_environment" {
  backend = "s3"

  config = {
    key    = "network.tfstate"
    bucket = var.bucket
    region = "eu-west-2"

    use_lockfile = true
  }
}

data "terraform_remote_state" "forms_ses" {
  backend = "s3"

  config = {
    key    = "ses.tfstate"
    bucket = var.bucket
    region = "eu-west-2"

    use_lockfile = true
  }
}


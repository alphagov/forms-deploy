terraform {
  backend "s3" {
    # bucket set in backend config file
    key    = "tempo.tfstate"
    region = "eu-west-2"

    use_lockfile = true
  }
}

provider "aws" {
  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = merge(var.default_tags,
      {
        Deployment = "${var.environment_name}/tempo"
      }
    )
  }
}

# Unauthenticated - only used for the github_ip_ranges data source (see
# infra/modules/tempo/security-groups.tf), which reads GitHub's public
# meta API and needs no token.
provider "github" {}

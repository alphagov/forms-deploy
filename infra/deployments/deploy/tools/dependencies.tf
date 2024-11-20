data "terraform_remote_state" "deploy_ecr" {
  backend = "s3"

  config = {
    key    = "ecr.tfstate"
    bucket = "gds-forms-deploy-tfstate"
    region = "eu-west-2"
  }
}

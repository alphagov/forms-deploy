module "pipeline" {
  source = "../../../modules/pipeline"

  terraform_deployment          = "forms-api"
  development_deployer_role_arn = "arn:aws:iam::498160065950:role/deployer-dev"

  source_repo   = "forms-api"
  source_branch = "main"
  image_name    = "forms-api-deploy"
}

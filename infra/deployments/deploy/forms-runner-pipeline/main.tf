module "pipeline" {
  source = "../../../modules/app-deploy-pipeline"

  development_deployer_role_arn = "arn:aws:iam::498160065950:role/deployer-dev"

  app_name            = "forms-runner"
  forms_deploy_branch = "code_pipeline"
}

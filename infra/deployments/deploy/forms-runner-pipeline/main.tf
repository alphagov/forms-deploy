module "pipeline" {
  source = "../../../modules/app-deploy-pipeline"

  app_name            = "forms-runner"
  forms_deploy_branch = "code_pipeline"
}

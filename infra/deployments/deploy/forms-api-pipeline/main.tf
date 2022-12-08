module "pipeline" {
  source = "../../../modules/app-deploy-pipeline"

  app_name            = "forms-api"
  forms_deploy_branch = "code_pipeline"
}

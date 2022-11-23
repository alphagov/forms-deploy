module "deployer_access" {
  source   = "../../../modules/deployer-access"
  env_name = "dev"

  codebuild_terraform_arn = "arn:aws:iam::711966560482:role/codebuild-forms-api-deploy-dev"
}

module "deployer_access" {
  source   = "../../../modules/deployer-access"
  env_name = "dev"

  codebuild_terraform_arns = [
    "arn:aws:iam::711966560482:role/codebuild-forms-api-deploy-dev",
    "arn:aws:iam::711966560482:role/codebuild-forms-admin-deploy-dev",
    "arn:aws:iam::711966560482:role/codebuild-forms-runner-deploy-dev"
  ]

}

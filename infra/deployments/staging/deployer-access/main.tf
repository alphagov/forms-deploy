module "deployer_access" {
  source   = "../../../modules/deployer-access"
  env_name = "staging"

  codebuild_terraform_arns = [
    "arn:aws:iam::711966560482:role/codebuild-forms-api-deploy-staging",
    "arn:aws:iam::711966560482:role/codebuild-forms-admin-deploy-staging",
    "arn:aws:iam::711966560482:role/codebuild-forms-runner-deploy-staging"
  ]

}

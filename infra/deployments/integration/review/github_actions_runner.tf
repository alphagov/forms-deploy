data "aws_caller_identity" "current" {}

resource "aws_iam_service_linked_role" "app_autoscaling" {
  aws_service_name = "ecs.application-autoscaling.amazonaws.com"
}

resource "aws_codebuild_source_credential" "github_credential" {
  auth_type   = "CODECONNECTIONS"
  server_type = "GITHUB"

  token = data.terraform_remote_state.account.outputs.codeconnection_arn
}

module "forms_admin" {
  source = "./gha-runner"

  application_name              = "forms-admin"
  application_source_repository = "https://github.com/alphagov/forms-admin"

  autoscaling_role_arn              = aws_iam_service_linked_role.app_autoscaling.arn
  aws_ecr_repository_arn            = module.forms_admin_container_repo.arn
  aws_ecs_cluster_arn               = aws_ecs_cluster.review.arn
  aws_ecs_cluster_name              = aws_ecs_cluster.review.name
  codestar_connection_arn           = var.codestar_connection_arn
  deploy_account_id                 = var.deploy_account_id
  dockerhub_password_parameter_arn  = aws_ssm_parameter.dockerhub_password.arn
  dockerhub_password_parameter_name = aws_ssm_parameter.dockerhub_password.name
  dockerhub_username_parameter_arn  = aws_ssm_parameter.dockerhub_username.arn
  dockerhub_username_parameter_name = aws_ssm_parameter.dockerhub_username.name
  task_execution_role_arn           = aws_iam_role.ecs_execution.arn
}

module "forms_runner" {
  source = "./gha-runner"

  application_name              = "forms-runner"
  application_source_repository = "https://github.com/alphagov/forms-runner"

  autoscaling_role_arn              = aws_iam_service_linked_role.app_autoscaling.arn
  aws_ecr_repository_arn            = module.forms_runner_container_repo.arn
  aws_ecs_cluster_arn               = aws_ecs_cluster.review.arn
  aws_ecs_cluster_name              = aws_ecs_cluster.review.name
  codestar_connection_arn           = var.codestar_connection_arn
  deploy_account_id                 = var.deploy_account_id
  dockerhub_password_parameter_arn  = aws_ssm_parameter.dockerhub_password.arn
  dockerhub_password_parameter_name = aws_ssm_parameter.dockerhub_password.name
  dockerhub_username_parameter_arn  = aws_ssm_parameter.dockerhub_username.arn
  dockerhub_username_parameter_name = aws_ssm_parameter.dockerhub_username.name
  task_execution_role_arn           = aws_iam_role.ecs_execution.arn
}

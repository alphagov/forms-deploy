module "forms_admin_container_repo" {
  source          = "./container-repository"
  repository_name = "forms-admin"
}

module "forms_runner_container_repo" {
  source          = "./container-repository"
  repository_name = "forms-runner"
}

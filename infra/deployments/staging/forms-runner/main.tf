module "forms_runner" {
  source             = "../../../modules/forms-runner"
  env_name           = "staging"
  image_tag          = "dan_test_4" # TODO: Make this a variable in future.
  desired_task_count = 1
  cpu                = 256
  memory             = 512
}

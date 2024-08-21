variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
  nullable    = true
  default     = null
}

module "forms_people" {
  source = "../../../modules/users"
}

data "aws_iam_role" "readonly_people_roles" {
  # Readonly roles are made for each of the people in these lists
  for_each = toset(concat(
    module.forms_people.with_role["deploy_admin"],
    module.forms_people.with_role["deploy_support"],
    module.forms_people.with_role["deploy_readonly"]
  ))
  name = "${each.value}-readonly"
}

locals {
  allowed_csv_role_assumers = var.forms_runner_settings.allow_human_readonly_roles_to_assume_csv_submission_role ? (
    [for role in data.aws_iam_role.readonly_people_roles : role.arn]
    ) : (
    []
  )
}

module "forms_runner" {
  source                                  = "../../../modules/forms-runner"
  env_name                                = var.environment_name
  root_domain                             = var.root_domain
  image_tag                               = var.image_tag
  cpu                                     = var.forms_runner_settings.cpu
  memory                                  = var.forms_runner_settings.memory
  min_capacity                            = var.forms_runner_settings.min_capacity
  max_capacity                            = var.forms_runner_settings.max_capacity
  api_base_url                            = "https://api.${var.root_domain}"
  admin_base_url                          = "https://admin.${var.root_domain}"
  enable_maintenance_mode                 = var.forms_runner_settings.enable_maintenance_mode
  cloudwatch_metrics_enabled              = var.forms_runner_settings.cloudwatch_metrics_enabled
  analytics_enabled                       = var.forms_runner_settings.analytics_enabled
  deploy_account_id                       = var.deploy_account_id
  csv_submission_enabled                  = var.forms_runner_settings.csv_submission_enabled
  csv_submission_enabled_for_form_ids     = var.forms_runner_settings.csv_submission_enabled_for_form_ids
  additional_csv_submission_role_assumers = local.allowed_csv_role_assumers

}

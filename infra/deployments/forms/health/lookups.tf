data "aws_lb" "forms_lb" {
  arn = data.terraform_remote_state.forms_environment.outputs.alb_arn
}

data "aws_lb_target_group" "forms_admin_tg" {
  arn = data.terraform_remote_state.forms_admin.outputs.target_group_arn
}

data "aws_lb_target_group" "forms_runner_tg" {
  arn = data.terraform_remote_state.forms_runner.outputs.target_group_arn
}

data "aws_lb_target_group" "forms_product_page_tg" {
  arn = data.terraform_remote_state.forms_product_page.outputs.target_group_arn
}

data "aws_s3_bucket" "logs_bucket" {
  bucket = "govuk-forms-alb-logs-${var.environment_name}"
}

data "aws_ssm_parameter" "pagerduty_email" {
  name = "/account/pagerduty-email"

  depends_on = [aws_ssm_parameter.pagerduty_email]
}

data "aws_ssm_parameter" "pagerduty_phone_number" {
  name = "/account/pagerduty-phone-number"

  depends_on = [aws_ssm_parameter.pagerduty_phone_number]
}

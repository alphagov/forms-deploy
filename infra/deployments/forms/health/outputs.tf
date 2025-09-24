data "aws_lb" "forms_lb" {
  arn = data.terraform_remote_state.forms_environment.outputs.alb_arn
}

data "aws_lb_target_group" "forms_admin_tg" {
  arn = data.terraform_remote_state.forms_admin.outputs.target_group_arn
}

data "aws_lb_target_group" "forms_runner_tg" {
  arn = data.terraform_remote_state.forms_runner.outputs.target_group_arn
}

output "load_balancer_name" {
  value = data.aws_lb.forms_lb.arn_suffix
}

output "forms_admin_target_group_name" {
  value = "targetgroup/${data.aws_lb_target_group.forms_admin_tg.arn_suffix}"
}

output "forms_runner_target_group_name" {
  value = "targetgroup/${data.aws_lb_target_group.forms_runner_tg.arn_suffix}"
}
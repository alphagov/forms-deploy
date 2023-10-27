locals {
  apps = ["forms-admin", "forms-api", "forms-runner", "forms-product-page"]
}

data "aws_lb" "alb" {
  name = "forms-${var.environment}"
}

data "aws_lb_target_group" "target_groups" {
  for_each = toset(local.apps)
  name     = "${each.key}-${var.environment}"
}
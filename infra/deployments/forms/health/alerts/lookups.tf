locals {
  apps       = ["forms-admin", "forms-api", "forms-runner", "forms-product-page"]
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_lb" "alb" {
  name = "forms-${var.environment}"
}

data "aws_lb_target_group" "target_groups" {
  for_each = toset(local.apps)
  name     = "${each.key}-${var.environment}"
}

data "aws_caller_identity" "current" {}
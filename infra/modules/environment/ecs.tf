resource "aws_ecs_cluster" "forms" {
  name = "forms-${var.env_name}"

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }
}

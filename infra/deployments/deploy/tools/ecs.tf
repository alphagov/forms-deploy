resource "aws_ecs_cluster" "tools" {
  name = "tools"

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }
}

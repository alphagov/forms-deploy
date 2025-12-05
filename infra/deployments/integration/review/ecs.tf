resource "aws_ecs_cluster" "review" {
  name = "review"

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }
}

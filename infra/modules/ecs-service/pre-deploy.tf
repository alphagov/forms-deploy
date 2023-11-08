resource "null_resource" "pre_deploy_script" {
  count = var.pre_deploy_script != "" ? 1 : 0

  provisioner "local-exec" {
    command     = var.pre_deploy_script
    interpreter = ["bash"]
    environment = {
      ECS_CLUSTER_ARN                = data.aws_ecs_cluster.forms.arn
      ECS_TASK_DEFINITION_ARN        = aws_ecs_task_definition.task.arn
      ECS_TASK_NETWORK_CONFIGURATION = jsonencode(local.ecs_service_network_configuration)
      CONTAINER_DEFINITION_JSON      = jsonencode(local.task_container_definition)
    }
  }

  triggers = {
    always_run = var.image
  }
}
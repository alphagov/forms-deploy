output "task_definition_name" {
  value = module.ecs_service.task_container_definition.name
}
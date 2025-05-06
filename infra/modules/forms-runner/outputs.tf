output "task_definition_name" {
  value = module.ecs_service.task_container_definition.name
}

output "kms_key_arn" {
  value = aws_kms_key.active_record_encryption.arn
}
output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

output "cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.this.arn
}

output "catlike_service_arn" {
  value       = aws_ecs_service.catlike.arn
  description = "ARN of the catlike ECS service"
}

output "catlike_service_name" {
  value       = aws_ecs_service.catlike.name
  description = "Name of the catlike ECS service"
}

output "doglike_service_arn" {
  value       = aws_ecs_service.doglike.arn
  description = "ARN of the doglike ECS service"
}

output "doglike_service_name" {
  value       = aws_ecs_service.doglike.name
  description = "Name of the doglike ECS service"
}

output "deployer_role_arn" {
  value       = aws_iam_role.deployer.arn
  description = "IAM role ARN for cross-account automation to UpdateService"
}

output "log_group_catlike" {
  value       = aws_cloudwatch_log_group.catlike.name
  description = "CloudWatch Logs log group for catlike"
}

output "log_group_doglike" {
  value       = aws_cloudwatch_log_group.doglike.name
  description = "CloudWatch Logs log group for doglike"
}

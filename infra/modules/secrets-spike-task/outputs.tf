output "catlike_cluster_name" {
  description = "ECS cluster name for catlike"
  value       = aws_ecs_cluster.catlike.name
}

output "catlike_cluster_arn" {
  description = "ECS cluster ARN for catlike"
  value       = aws_ecs_cluster.catlike.arn
}

output "doglike_cluster_name" {
  description = "ECS cluster name for doglike"
  value       = aws_ecs_cluster.doglike.name
}

output "doglike_cluster_arn" {
  description = "ECS cluster ARN for doglike"
  value       = aws_ecs_cluster.doglike.arn
}

output "catlike_service_arn" {
  value       = local.catlike_service_arn
  description = "ARN of the catlike ECS service"
}

output "catlike_service_name" {
  value       = aws_ecs_service.catlike.name
  description = "Name of the catlike ECS service"
}

output "doglike_service_arn" {
  value       = local.doglike_service_arn
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

output "catlike_event_rule_name" {
  value       = module.catlike_redeploy.rule_name
  description = "EventBridge rule name for catlike"
}

output "catlike_event_rule_arn" {
  value       = module.catlike_redeploy.rule_arn
  description = "EventBridge rule arn for catlike"
}

output "doglike_event_rule_name" {
  value       = module.doglike_redeploy.rule_name
  description = "EventBridge rule name for doglike"
}

output "doglike_event_rule_arn" {
  value       = module.doglike_redeploy.rule_arn
  description = "EventBridge rule arn for doglike"
}

output "catlike_lambda_name" {
  value       = module.catlike_redeploy.lambda_name
  description = "Lambda name for catlike redeploy"
}

output "catlike_lambda_arn" {
  value       = module.catlike_redeploy.lambda_arn
  description = "Lambda arn for catlike redeploy"
}

output "doglike_lambda_name" {
  value       = module.doglike_redeploy.lambda_name
  description = "Lambda name for doglike redeploy"
}

output "doglike_lambda_arn" {
  value       = module.doglike_redeploy.lambda_arn
  description = "Lambda arn for doglike redeploy"
}

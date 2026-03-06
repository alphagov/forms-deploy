output "vpc_id" {
  description = "The id of the VPC in which the review apps resources exist"
  value       = module.vpc.vpc_id
}

output "ecs_cluster_id" {
  description = "The id of the ECS cluster used for review apps"
  value       = aws_ecs_cluster.review.id
}

output "ecs_task_execution_role_arn" {
  description = "The ARN of the role that review app tasks should use as their task execution role"
  value       = aws_iam_role.ecs_execution.arn
}

output "private_subnet_ids" {
  description = "The ids of all private subnets within the VPC. Used by applications deploying to the review environment to place ECS tasks."
  value       = module.vpc.private_subnet_ids
}

output "review_apps_security_group_id" {
  description = "The id of the security group to be used by review apps"
  value       = aws_security_group.review_apps.id
}

output "review_apps_log_group_name" {
  description = "The CloudWatch log group to which review apps should send their logs"
  value       = aws_cloudwatch_log_group.review_apps.name
}

output "forms_admin_container_repo_url" {
  description = "The URL of the forms-admin container repository"
  value       = module.forms_admin_container_repo.url
}

output "forms_runner_container_repo_url" {
  description = "The URL of the forms-runner container repository"
  value       = module.forms_runner_container_repo.url
}

output "forms_product_page_container_repo_url" {
  description = "The URL of the forms-product-page container repository"
  value       = module.forms_product_page_container_repo.url
}

output "traefik_basic_auth_credentials" {
  description = "The credentials Traefik uses for basic authentication in front of review apps"
  value       = data.aws_ssm_parameter.traefik_basic_auth_credentials.value
  sensitive   = true
}

output "github_actions_role_arns" {
  description = "IAM role ARNs for GitHub Actions review app deployments"
  value = {
    for app, role in aws_iam_role.github_actions : app => role.arn
  }
}

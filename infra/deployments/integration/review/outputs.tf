output "vpc_id" {
  description = "The id of the VPC in which the review apps resources exist"
  value       = module.vpc.vpc_id
}

output "ecs_cluster_id" {
  description = "The id of the ECS cluster used for reviwe apps"
  value       = aws_ecs_cluster.review.id
}

output "forms_admin_container_repo_url" {
  description = "The URL of the forms admin container repository"
  value       = module.forms_admin_container_repo.url
}

output "vpc_id" {
  description = "The id of the VPC in which the review apps resources exist"
  value       = module.vpc.vpc_id
}

output "ecs_cluster_id" {
  description = "The id of the ECS cluster used for reviwe apps"
  value       = aws_ecs_cluster.review.id
}

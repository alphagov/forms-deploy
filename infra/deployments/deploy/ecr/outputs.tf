output "ecr_repository_url" {
  value       = aws_ecr_repository.pipeline_visualiser.repository_url
  description = "ECR repository URL for the pipeline visualizer."
}

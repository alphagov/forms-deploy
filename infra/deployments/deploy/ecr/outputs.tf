output "pipeline_visualiser_ecr_repository_url" {
  value       = aws_ecr_repository.pipeline_visualiser.repository_url
  description = "ECR repository URL for the pipeline visualizer."
}

output "e2e_tests_ecr_repository_url" {
  value       = aws_ecr_repository.end_to_end_tests.repository_url
  description = "ECR repository URL for the end to end tests."
}

output "forms_product_page_ecr_repository_url" {
  value       = aws_ecr_repository.forms_product_page.repository_url
  description = "ECR repository URL for forms-product-page image."
}

output "forms_runner_ecr_repository_url" {
  value       = aws_ecr_repository.forms_runner.repository_url
  description = "ECR repository URL for forms-runner image."
}

output "forms_api_ecr_repository_url" {
  value       = aws_ecr_repository.forms_api.repository_url
  description = "ECR repository URL for forms-api image."
}

output "forms_admin_ecr_repository_url" {
  value       = aws_ecr_repository.forms_admin.repository_url
  description = "ECR repository URL for forms-admin image."
}

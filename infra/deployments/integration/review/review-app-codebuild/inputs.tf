variable "application_name" {
  description = "Name of the application (forms-admin, forms-runner, forms-product-page)"
  type        = string
}

variable "action" {
  description = "Action type: deploy or destroy"
  type        = string
  validation {
    condition     = contains(["deploy", "destroy"], var.action)
    error_message = "Action must be 'deploy' or 'destroy'"
  }
}

variable "github_repository" {
  description = "GitHub repository URL"
  type        = string
}

variable "codeconnection_arn" {
  description = "ARN of the CodeConnections connection for GitHub"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "S3 bucket for CodeBuild artifacts"
  type        = string
}

variable "ecs_cluster_arn" {
  description = "ARN of the ECS cluster where the review app service runs"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster where the review app service runs"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository that stores the application's container images"
  type        = string
}

variable "task_execution_role_arn" {
  description = "ARN of the IAM role used by ECS tasks for pulling images and writing logs"
  type        = string
}

variable "autoscaling_role_arn" {
  description = "ARN of the IAM role used by Application Auto Scaling for ECS services"
  type        = string
}

variable "deploy_account_id" {
  description = "AWS account ID of the deploy account, used for accessing shared base images in ECR"
  type        = string
}

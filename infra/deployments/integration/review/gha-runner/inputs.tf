variable "application_name" {
  description = "The name of the application for which this will serve as a GitHub Actions runner"
  type        = string
}

variable "application_source_repository" {
  description = "The URL of the source code repository for the application. It should use the https scheme."
  type        = string
}

variable "aws_ecs_cluster_arn" {
  description = "The ARN of the AWS ECS cluster that the runner will need permission to work with"
  type        = string
}

variable "aws_ecs_cluster_name" {
  description = "The name of the AWS ECS cluster that the runner will need permission to work with"
  type        = string
}

variable "aws_ecr_repository_arn" {
  description = "The ARN of the AWS ECR repository that the runner will need permission to push and pull images to and from"
  type        = string
}

variable "codestar_connection_arn" {
  description = "The ARN of the AWS CodeStar connection to use for getting GitHub access credentials"
  type        = string
}

variable "task_execution_role_arn" {
  description = "The ARN of the IAM role used by AWS ECS when executing a task"
  type        = string
}

variable "autoscaling_role_arn" {
  description = "The ARN of the service-linked IAM role used by the application autoscaler. This is needed to allow that role to pass the runner role to AWS ECS when it scales."
  type        = string
}

variable "dockerhub_username_parameter_arn" {
  description = "The ARN of the AWS SSM Parameter Storm parameter containing the dockerhub username"
  type        = string
}

variable "dockerhub_username_parameter_name" {
  description = "The name of the AWS SSM Parameter Storm parameter containing the dockerhub username"
  type        = string
}

variable "dockerhub_password_parameter_arn" {
  description = "The ARN of the AWS SSM Parameter Storm parameter containing the dockerhub password"
  type        = string
}

variable "dockerhub_password_parameter_name" {
  description = "The name of the AWS SSM Parameter Storm parameter containing the dockerhub password"
  type        = string
}

variable "deploy_account_id" {
  description = "The ID of the deploy account. This is used to grant permissions to use the container registry in the deploy account."
  type        = string
}

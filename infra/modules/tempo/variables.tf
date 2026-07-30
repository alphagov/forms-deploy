variable "env_name" {
  type        = string
  description = "The name of the environment, e.g. dev"
}

variable "root_domain" {
  type        = string
  description = "The root domain for this deployment of GOV.UK Forms, e.g. dev.forms.service.gov.uk"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID in which the ECS service resides"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block of the VPC"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The list of private subnet ids used in the ECS service network configuration"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "The ARN of the ECS cluster to run the service in"
}

variable "alb_listener_arn" {
  type        = string
  description = "The ARN of the public load balancer listener that Grafana will be attached to"
}

variable "internal_alb_listener_arn" {
  type        = string
  description = "The ARN of the internal load balancer listener that the Tempo OTLP receiver will be attached to"
}

variable "cloudfront_secret" {
  type        = string
  description = "The secret header value that CloudFront sends to verify requests"
  sensitive   = true
}

variable "listener_priority" {
  type        = number
  description = "The priority for the public ALB listener rule (Grafana UI). Must be distinct across all invocations in a deployment."
}

variable "internal_listener_priority" {
  type        = number
  description = "The priority for the internal ALB listener rule (Tempo OTLP ingestion). Must be distinct across all invocations in a deployment."
}

variable "image_tag" {
  type        = string
  description = "The tag to deploy from the tempo/grafana ECR repositories this module creates (see README.md for how images get there)"
  default     = "latest"
}

variable "cpu" {
  type        = number
  description = "Total CPU units for the task (tempo + grafana + prometheus share this, no per-container limits). Must be a valid Fargate CPU tier."
  default     = 2048
}

variable "memory" {
  type        = number
  description = "Total memory (MB) for the task (tempo + grafana + prometheus share this, no per-container limits). Must be a valid Fargate value for the chosen cpu tier."
  default     = 4096
}

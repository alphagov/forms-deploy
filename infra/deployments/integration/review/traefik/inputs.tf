variable "ecs_cluster_arn" {
  description = "ARN of the ECS cluster in which to run Traefik"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID in which to create the ALB target group"
  type        = string
}

variable "alb_tls_listener_arn" {
  description = "The ARN of the ALB listener to which the listener rule needs to be attached"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet ids required for the ECS service network configuration"
  type = list(string)
}

variable "cidr_block" {
  description = "The CIDR block required for the security group configuration"
  type        = string
}
variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
}

variable "root_domain" {
  type        = string
  description = "The root domain for this deployment of GOV.UK Forms. For example: forms.service.gov.uk"
}

variable "image_tag" {
  type     = string
  nullable = true
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "zendesk_subdomain" {
  description = "The Zendesk tenant the support form should create tickets on"
  default     = "govuk"
  type        = string
}

variable "admin_base_url" {
  description = "The url for redirecting to forms-admin"
  type        = string
}
variable "min_capacity" {
  description = "Sets the minimum number of instances"
  type        = number
}

variable "max_capacity" {
  description = "Sets the maximum number of instances"
  type        = number
}

variable "deploy_account_id" {
  type        = string
  description = "The account number for the deploy account"
}

variable "container_repository" {
  description = "The complete URI of the container repository."
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "The VPC in which the service resides"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block associated with the service's VPC"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The list of private subnet ids used in the ECS service network configuration"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "The arn for the ECS cluster"
}

variable "alb_arn_suffix" {
  type        = string
  description = "The suffix of the Application Load Balancer ARN. Used with CloudWatch metrics"
}

variable "alb_listener_arn" {
  type        = string
  description = "The ARN of the load balancer listener to which forms-product-page will be attached"
}

variable "cloudfront_secret" {
  type        = string
  description = "The secret header value that CloudFront sends to verify requests"
  sensitive   = true
}

variable "kinesis_subscription_role_arn" {
  description = "The arn of the role that is allowed to subscribe to the kinesis stream"
  type        = string
}

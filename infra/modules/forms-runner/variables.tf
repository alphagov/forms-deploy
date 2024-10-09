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

variable "admin_base_url" {
  description = "The url for redirecting to forms-admin"
  type        = string
}

variable "api_base_url" {
  description = "The url for connecting to forms-api"
  type        = string
}

variable "enable_maintenance_mode" {
  description = "Controls whether the maintenance page is shown"
  type        = bool
}

variable "maintenance_mode_bypass_ips" {
  description = "List of IP addresses which will bypass the maintenance mode message"
  type        = string
  default     = "213.86.153.211/32, 213.86.153.212/32, 213.86.153.213/32,213.86.153.214/32, 213.86.153.231/32, 213.86.153.235/32, 213.86.153.236/32, 213.86.153.237/32, 51.149.8.0/25, 51.149.8.128/29, 51.149.9.112/29, 51.149.9.240/29"
}

variable "rails_max_threads" {
  description = "The number of request threads run by the Puma server"
  type        = number
  default     = 25
}

variable "min_capacity" {
  description = "Sets the minimum number of instances"
  type        = number
}

variable "max_capacity" {
  description = "Sets the maximum number of instances"
  type        = number
}

variable "cloudwatch_metrics_enabled" {
  description = "Enables metrics being sent to CloudWatch"
  type        = bool
  default     = false
}

variable "analytics_enabled" {
  description = "Enables Google analytics and the cookie banner"
  type        = bool
  default     = false
}

variable "deploy_account_id" {
  type        = string
  description = "the account number for the deploy account"
}

variable "api_v2_enabled" {
  description = "Use v2 API of forms-api when enabled."
  type        = bool
  default     = false
}

variable "additional_submissions_to_s3_role_assumers" {
  description = "A list of role ARNs which are also allowed to assume the role for submissions to s3"
  type        = list(string)
}

variable "elasticache_port" {
  description = "The port number for the Redis ElastiCache cluster"
  type        = number
}

variable "elasticache_primary_endpoint_address" {
  description = "The Redis ElastiCache unique address used to by applications to connect to the database"
  type        = string
}

variable "container_repository" {
  description = "The name of the container repository to use"
  type        = string
}
variable "vpc_id" {
  type        = string
  description = "vpc_id"
}

variable "vpc_cidr_block" {
  type        = string
  description = "vpc_cidr_block"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet ids used in the ECS service network configuration"
}

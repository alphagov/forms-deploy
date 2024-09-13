variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
}

variable "root_domain" {
  type        = string
  description = "The root domain for this deployment of GOV.UK Forms. For example: forms.service.gov.uk"
}

variable "container_repository" {
  type        = string
  description = "The name of the container repository to use"
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
  description = "the account number for the deploy account"
}
variable "vpc_id" {
  type        = string
  description = "vpc_id"
}

variable "vpc_cidr_block" {
  type        = string
  description = "vpc_cidr_block"
}

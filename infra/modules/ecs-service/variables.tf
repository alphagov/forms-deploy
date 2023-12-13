variable "env_name" {
  type = string

  validation {
    condition     = contains(["user-research", "dev", "staging", "production"], var.env_name)
    error_message = "Valid values for env_name are: user-research, dev, staging, production"
  }
}

variable "sub_domain" {
  type        = string
  description = "The subdomain for this service."
  validation {
    condition     = contains(["submit", "admin", "www", "api"], var.sub_domain)
    error_message = "Valid values for sub_domain are: submit, admin, www, api"
  }
}


variable "application" {
  type        = string
  description = "The name of the application e.g. forms-admin"
  validation {
    condition     = contains(["forms-admin", "forms-runner", "forms-api", "forms-product-page"], var.application)
    error_message = "Valid values for application are: forms-admin, forms-runner, forms-api, forms-product-page"
  }
}

variable "image" {
  type        = string
  description = "The image in ECR to deploy"
}

variable "cpu" {
  type        = string
  description = "The amount of CPU to provision in the ECS task."
}

variable "memory" {
  type        = string
  description = "The amount of memory to provision in the ECS task."
}

variable "environment_variables" {
  type        = list(any)
  default     = []
  description = "Environment variables to set in the task environment"
}

variable "secrets" {
  type        = list(any)
  default     = []
  description = "Secret values to look up form SSM Parameter store and set in the task environment"
}

variable "container_port" {
  type        = number
  description = "The port that the container process listens on."
}

variable "permit_internet_egress" {
  type        = bool
  default     = false
  description = "If true then the app's security group will permit egress to the internet on port 443"
}

variable "permit_postgres_egress" {
  type        = bool
  default     = false
  description = "If true then the app's security group will permit egress to the postgres on port 5432"
}

variable "permit_redis_egress" {
  type        = bool
  default     = false
  description = "If true then the app's security group will permit egress to the redis on port 6379"
}

variable "ecs_task_role_policy_json" {
  type        = string
  description = "JSON policy to be attached to the ECS task role"
  default     = ""
}

variable "pre_deploy_script" {
  type        = string
  default     = ""
  description = <<EOF
Absolute path to a script to run before a new task definition is run. Arguments are given as environment variables

ECS_CLUSTER_ARN: The ECS cluster ARN
ECS_TASK_DEFINITION_ARN: The task definition ARN
ECS_TASK_NETWORK_CONFIGURATION: The network configuration to use when running the task
CONTAINER_DEFINITION_JSON: The task's container definition in JSON

If left empty, no script will be run.
EOF
}

variable "scaling_rules" {
  type = object({
    min_capacity                                = number
    max_capacity                                = number
    p95_response_time_scaling_threshold_seconds = number
    scale_in_cooldown                           = number
    scale_out_cooldown                          = number
  })
}

variable "deploy_maximum_percent" {
  type        = string
  description = <<EOF
Upper limit (as a percentage of the service's current count) of the number of running tasks that can be running in a service during a deployment

See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-instance-draining.html#draining-service-behavior

Defaulting to 200% allows ECS to start as many new instances as there are old instances before draining the old ones.
EOF

  default = "200"
}
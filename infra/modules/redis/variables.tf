variable "env_name" {
  type = string

  validation {
    condition     = contains(["user-research", "dev", "staging", "production"], var.env_name)
    error_message = "Valid values for env_name are: user-research, dev, staging, production"
  }
}

variable "redis_version" {
  type    = string
  default = "3.2.6"
}

variable "apply_immediately" {
  type        = bool
  description = "If false then changes are applied during the maintenance window"
  default     = false
}

variable "availability_zones" {
  type        = list(string)
  description = "The availbility zones to run the redis cluster in"
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "engine_version" {
  default     = "6.2"
  description = "The version of Redis to use"
}

variable "snapshot_retention_limit" {
  default = 30
}

variable "number_cache_clusters" {
  type        = string
  description = "How many cache clusters to run, must >= number of AZs"
  default     = 3
}

variable "automatic_failover_enabled" {
  default     = true
  description = "If the primary node fails it will failover to a replica"
}

variable "redis_parameters" {
  description = "Redis parameters to change from the defaults"
  type        = list(map(any))
  default     = []
}

variable "redis_node_type" {
  type        = string
  description = "Controls the type and size of the instances which each node runs on"
  default     = "cache.t3.micro"
}

variable "redis_maintenance_window" {
  type        = string
  default     = "mon:06:00-mon:07:00"
  description = "When planned maintenance will take place such as minor version upgardes"
}

variable "redis_snapshot_window" {
  description = "The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster. The minimum snapshot window is a 60 minute period"
  type        = string
  default     = "04:30-05:30"
}

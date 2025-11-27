variable "env_name" {
  type = string
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
  description = "The availability zones to run the redis cluster in"
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "engine" {
  description = "The cache engine configuration including name, version, and parameter group"
  default = {
    name            = "redis"
    version         = "7.0"
    parameter_group = "redis7"
  }
  type = object({
    name            = string
    version         = string
    parameter_group = string
  })
}

variable "number_cache_clusters" {
  type        = string
  description = "How many cache clusters to run, must >= number of AZs"
  default     = 3
}

variable "automatic_failover_enabled" {
  description = "If the primary node fails it will failover to a replica"
  default     = true
  type        = bool
}

variable "parameter_group_families" {
  description = "Parameter group families and the redis engine version they are compatible with"
  type        = map(string)
  default = {
    "redis6"  = "redis6.x"
    "redis7"  = "redis7"
    "valkey8" = "valkey8"
  }
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
  description = "When planned maintenance will take place such as minor and major version upgrades"
  default     = "tue:03:00-tue:04:00"
}

variable "redis_snapshot_window" {
  type        = string
  description = "The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster. The minimum snapshot window is a 60 minute period"
  default     = "04:30-05:30"
}

variable "vpc_id" {
  type        = string
  description = "Id of the VPC in which the database will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet ids which should form the database's subnet group"
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks from which ingress will be permitted"
}

variable "multi_az_enabled" {
  description = "Enable multi-availability zone support for Redis cluster. Improves resilience during planned maintenance and AZ failures."
  type        = bool
  default     = false
}

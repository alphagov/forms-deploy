variable "vpc_id" {
  description = "The id of the VPC in which the ALB and associated resources will live"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "The id of each subnet the ALB should be placed into"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "There must be at least one subnet id"
  }
}

variable "environment" {
  type = string
}

variable "account_id" {
  type = string
}

variable "databases" {
  type    = list(string)
  default = ["forms-api", "forms-admin"]
}

variable "container_image" {
  type = string
}

variable "s3_name" {
  type        = string
  description = "The name of the S3 bucket to configure for log shipping"
}

variable "destination" {
  type        = string
  description = "The destination for log shipping. Valid values are 'cribl' or 'csls'."
  default     = "cribl"

  validation {
    condition     = contains(["cribl", "csls"], var.destination)
    error_message = "Invalid destination. Valid values are 'cribl' or 'csls'."
  }
}

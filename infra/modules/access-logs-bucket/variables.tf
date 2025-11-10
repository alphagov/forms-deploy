variable "bucket_name" {
  type        = string
  description = "Name of the access logs bucket"
}

variable "send_access_logs_to_cyber" {
  type        = bool
  description = "Whether access logs should be sent to cyber"
  default     = true
  nullable    = false
}

variable "extra_bucket_policies" {
  type        = list(string)
  description = "Extra bucket policies to apply to this bucket. List of json policies"
  default     = []
}

variable "access_log_shipping_destination" {
  type        = string
  description = "The destination for log shipping. Valid values are 'cribl' or 'csls'."
  default     = "cribl"

  validation {
    condition     = contains(["cribl", "csls"], var.access_log_shipping_destination)
    error_message = "Invalid destination. Valid values are 'cribl' or 'csls'."
  }
}

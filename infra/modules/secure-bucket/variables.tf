variable "name" {
  type = string
}

variable "extra_bucket_policies" {
  type        = list(string)
  description = "extra bucket policies to apply to this bucket. List of json policies"
  default     = []
}

variable "AES256_encryption_configuration" {
  type        = bool
  description = "Whether to use AES256 as the algorithm for server side encryption. If false, the caller should set their own configuration"
  default     = true
  nullable    = false
}
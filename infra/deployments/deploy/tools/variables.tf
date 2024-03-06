variable "pipeline_visualiser_container_image_uri" {
  type        = string
  description = "URI of the pipeline visualiser image to deploy"
  nullable    = true
  default     = null
}

variable "pipeline_source_branch" {
  type        = string
  description = "The name of the Git branch from which to source changes"
  default     = "main"
}

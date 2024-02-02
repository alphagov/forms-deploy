variable "deploy-forms-product-page-container" {
  description = "Configuration options for the deploy-forms-product-page-container pipeline"
  type = object({
    trigger_on_tag_pattern = string
  })
}
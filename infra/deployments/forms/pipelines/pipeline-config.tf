variable "deploy-forms-product-page-container" {
  description = "Configuration options for the deploy-forms-product-page-container pipeline"
  type = object({
    # The container image tag pattern that should cause the pipeline to run
    trigger_on_tag_pattern = string

    # Should the image have a new tag applied at the end of a successful pipeline run?
    retag_image_on_success = bool

    # Sed expression used to generate the new tag. This will be run against the tag that triggerd the pipeline.
    # The resulting tag can contain "${EPOCH_SECONDS}" and this will be replaced with the timestamp at runtime
    retagging_sed_expression = string
  })
}
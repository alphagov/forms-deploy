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

    # It isn't possible to perform the end-to-end tests in the user-reseach environment because
    # it doesn't have Auth0 configured. Therefore we need to be able disable that step there.
    disable_end_to_end_tests = bool
  })
}

variable "deploy-forms-runner-container" {
  description = "Configuration options for the deploy-forms-runner-container pipeline"
  type = object({
    # The container image tag pattern that should cause the pipeline to run
    trigger_on_tag_pattern = string

    # Should the image have a new tag applied at the end of a successful pipeline run?
    retag_image_on_success = bool

    # Sed expression used to generate the new tag. This will be run against the tag that triggerd the pipeline.
    # The resulting tag can contain "${EPOCH_SECONDS}" and this will be replaced with the timestamp at runtime
    retagging_sed_expression = string

    # It isn't possible to perform the end-to-end tests in the user-reseach environment because
    # it doesn't have Auth0 configured. Therefore we need to be able disable that step there.
    disable_end_to_end_tests = bool
  })
}

variable "deploy-forms-api-container" {
  description = "Configuration options for the deploy-forms-api-container pipeline"
  type = object({
    # The container image tag pattern that should cause the pipeline to run
    trigger_on_tag_pattern = string

    # Should the image have a new tag applied at the end of a successful pipeline run?
    retag_image_on_success = bool

    # Sed expression used to generate the new tag. This will be run against the tag that triggerd the pipeline.
    # The resulting tag can contain "${EPOCH_SECONDS}" and this will be replaced with the timestamp at runtime
    retagging_sed_expression = string

    # It isn't possible to perform the end-to-end tests in the user-reseach environment because
    # it doesn't have Auth0 configured. Therefore we need to be able disable that step there.
    disable_end_to_end_tests = bool
  })
}

variable "apply-terraform" {
  description = "Configuration options for the apply-terraform pipeline"
  type = object({
    # The source of pipeline triggers.
    # Valid values are:
    #
    # * GIT
    #   New commits to the source branch will trigger the pipeline
    # * EVENT
    #   The pipeline will be triggered by AWS EventBridge, based on the completion of a previous pipeline
    # * MANUAL
    #   The pipeline will never automatically run. It must be run from the AWS console
    pipeline_trigger = string

    # The source branch to watch when pipeline_trigger = GIT
    # When pipeline_trigger = EVENT|MANUAL, the 'main' branch will be used as a source, but will not be a trigger
    git_source_branch = string

    # The name of the pipeline whose success will trigger the pipeline when pipeline_trigger = EVENT
    previous_stage_name = string
  })

  validation {
    condition     = contains(["GIT", "EVENT", "MANUAL"], var.apply-terraform.pipeline_trigger)
    error_message = "Pipeline trigger must be one of [GIT, EVENT, MANUAL]"
  }

  validation {
    condition = (
      var.apply-terraform.pipeline_trigger == "GIT" ?
      var.apply-terraform.git_source_branch != ""
    : true)
    error_message = "Git source branch must be set when pipeline trigger is GIT"
  }

  validation {
    condition = (
      var.apply-terraform.pipeline_trigger == "EVENT" ?
      var.apply-terraform.previous_stage_name != ""
    : true)
    error_message = "Previous stage name must be set when pipeline trigger is EVENT"
  }

}
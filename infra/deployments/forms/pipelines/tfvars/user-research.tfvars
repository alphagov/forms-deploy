deploy-forms-product-page-container = {
  trigger_on_tag_pattern   = "prod-*" # User-research uses the same images as prod
  retag_image_on_success   = false
  retagging_sed_expression = ""
  disable_end_to_end_tests = true
}

deploy-forms-runner-container = {
  trigger_on_tag_pattern   = "prod-*" # User-research uses the same images as prod
  retag_image_on_success   = false
  retagging_sed_expression = ""
  disable_end_to_end_tests = true
}

deploy-forms-api-container = {
  trigger_on_tag_pattern   = "prod-*" # User-research uses the same images as prod
  retag_image_on_success   = false
  retagging_sed_expression = ""
  disable_end_to_end_tests = true
}

apply-terraform = {
  pipeline_trigger    = "EVENT"
  git_source_branch   = null
  previous_stage_name = "staging"
}
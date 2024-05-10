deploy-forms-product-page-container = {
  trigger_on_tag_pattern   = "stg-*"
  retag_image_on_success   = true
  retagging_sed_expression = "s/stg-\\(.*\\)/prod-\\1/" # "This was OK in production"
  disable_end_to_end_tests = false
}

deploy-forms-runner-container = {
  trigger_on_tag_pattern   = "stg-*"
  retag_image_on_success   = true
  retagging_sed_expression = "s/stg-\\(.*\\)/prod-\\1/" # "This was OK in production"
  disable_end_to_end_tests = false
}

deploy-forms-api-container = {
  trigger_on_tag_pattern   = "stg-*"
  retag_image_on_success   = true
  retagging_sed_expression = "s/stg-\\(.*\\)/prod-\\1/" # "This was OK in production"
  disable_end_to_end_tests = false
}

deploy-forms-admin-container = {
  trigger_on_tag_pattern   = "stg-*"
  retag_image_on_success   = true
  retagging_sed_expression = "s/stg-\\(.*\\)/prod-\\1/" # "This was OK in production"
  disable_end_to_end_tests = false
}

apply-terraform = {
  pipeline_trigger    = "EVENT"
  git_source_branch   = null
  previous_stage_name = "staging"
}
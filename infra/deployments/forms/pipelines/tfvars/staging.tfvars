deploy-forms-product-page-container = {
  trigger_on_tag_patterns  = ["merged-*"]
  retag_image_on_success   = true
  retagging_sed_expression = "s/merged-\\(.*\\)/stg-\\1/" # "This was OK in staging"
  disable_end_to_end_tests = false
}

deploy-forms-runner-container = {
  trigger_on_tag_patterns  = ["merged-*"]
  retag_image_on_success   = true
  retagging_sed_expression = "s/merged-\\(.*\\)/stg-\\1/" # "This was OK in staging"
  disable_end_to_end_tests = false
}

deploy-forms-api-container = {
  trigger_on_tag_patterns  = ["merged-*"]
  retag_image_on_success   = true
  retagging_sed_expression = "s/merged-\\(.*\\)/stg-\\1/" # "This was OK in staging"
  disable_end_to_end_tests = false
}

deploy-forms-admin-container = {
  trigger_on_tag_patterns  = ["merged-*"]
  retag_image_on_success   = true
  retagging_sed_expression = "s/merged-\\(.*\\)/stg-\\1/" # "This was OK in staging"
  disable_end_to_end_tests = false
}

apply-terraform = {
  pipeline_trigger    = "GIT"
  git_source_branch   = "main"
  previous_stage_name = null
}
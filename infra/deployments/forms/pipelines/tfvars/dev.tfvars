deploy-forms-product-page-container = {
  trigger_on_tag_pattern = "dev-*"

  # Don't re-tag at the end. A successful run in dev should not trigger a path to production.
  # That is triggered by a merge to main in the relevant repository
  retag_image_on_success   = false
  retagging_sed_expression = ""
  disable_end_to_end_tests = false
}

deploy-forms-runner-container = {
  trigger_on_tag_pattern = "dev-*"

  # Don't re-tag at the end. A successful run in dev should not trigger a path to production.
  # That is triggered by a merge to main in the relevant repository
  retag_image_on_success   = false
  retagging_sed_expression = ""
  disable_end_to_end_tests = false
}

apply-terraform = {
  pipeline_trigger    = "MANUAL"
  git_source_branch   = "poc-pipelines-in-environments"
  previous_stage_name = ""
}
deploy-forms-product-page-container = {
  trigger_on_tag_pattern = "dev-*"

  # Don't re-tag at the end. A successful run in dev should not trigger a path to production.
  # That is triggered by a merge to main in the relevant repository
  retag_image_on_success   = false
  retagging_sed_expression = ""
}
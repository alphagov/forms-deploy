deploy-forms-product-page-container = {
  trigger_on_tag_pattern   = "stg-*"
  retag_image_on_success   = true
  retagging_sed_expression = "s/stg-\\(.*\\)/prod-\\1/" # Staging -> Prod promotion
}
deploy-forms-product-page-container = {
  trigger_on_tag_pattern   = "prod-*"
  retag_image_on_success   = false # There are no further stages beyond production
  retagging_sed_expression = ""
}
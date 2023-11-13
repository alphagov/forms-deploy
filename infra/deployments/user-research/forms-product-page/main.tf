variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_product_page" {
  #checkov:skip=CKV2_FORMS_AWS_2:We're OK with 2 instances in UR environment
  source         = "../../../modules/forms-product-page"
  env_name       = "user-research"
  image_tag      = var.image_tag
  cpu            = 256
  memory         = 512
  admin_base_url = "https://admin.research.forms.service.gov.uk"
  min_capacity   = 3
  max_capacity   = 3
}

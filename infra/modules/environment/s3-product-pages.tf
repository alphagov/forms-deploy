locals {
  bucket_names = {
    dev           = "dev.forms.service.gov.uk",
    staging       = "staging.forms.service.gov.uk",
    user-research = "research.forms.service.gov.uk",
    production    = "forms.service.gov.uk"
  }
}

module "product_pages_s3_bucket" {
  source = "../secure-bucket"
  name   = lookup(local.bucket_names, var.env_name)
}

resource "aws_s3_bucket_website_configuration" "product_pages_s3_redirect" {
  bucket = module.product_pages_s3_bucket.name

  redirect_all_requests_to {
    host_name = "www.${lookup(local.bucket_names, var.env_name)}"
    protocol  = "https"
  }
}

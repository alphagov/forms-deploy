module "error_page_bucket" {
  source = "../../public-bucket"
  name   = "govuk-forms-${var.env_name}-error-page"
}

resource "aws_s3_object" "error_page_html" {
  bucket       = module.error_page_bucket.name
  key          = "/cloudfront/error_page.html"
  source       = "${path.module}/html/error_page.html"
  content_type = "text/html"
}

module "error_page_bucket" {
  source = "../public-bucket"

  access_logging_enabled = true
  name                   = "govuk-forms-${var.env_name}-error-page"

  send_access_logs_to_cyber = false
}

locals {
  content_type_map = {
    "js"    = "application/json"
    "html"  = "text/html"
    "css"   = "text/css"
    "png"   = "image/png"
    "jpg"   = "image/jpeg"
    "svg"   = "image/svg+xml"
    "woff"  = "font/woff"
    "woff2" = "font/woff2"
    "ico"   = "image/x-icon"
  }
}

resource "aws_s3_object" "error_page_html" {
  for_each = fileset("${path.module}/html/", "**")

  bucket       = module.error_page_bucket.name
  key          = "/cloudfront/${each.value}"
  source       = "${path.module}/html/${each.value}"
  content_type = lookup(local.content_type_map, reverse(split(".", each.value))[0], "binary/octet-stream")
  etag         = filemd5("${path.module}/html/${each.value}")
}

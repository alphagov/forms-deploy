locals {
  athena_results_bucket_name = "govuk-forms-${var.env_name}-grafana-athena-results"
}

module "athena_results_bucket" {
  source             = "../secure-bucket"
  name               = local.athena_results_bucket_name
  versioning_enabled = false
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_results" {
  bucket = module.athena_results_bucket.name

  rule {
    id     = "expire_query_results"
    status = "Enabled"
    expiration {
      days = 7
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    filter {}
  }
}

resource "aws_athena_workgroup" "grafana" {
  name        = local.name
  description = "Queries run by the Grafana Athena data source"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    bytes_scanned_cutoff_per_query     = 1024 * 1024 * 1024 # 1 GiB

    engine_version {
      selected_engine_version = "Athena engine version 3"
    }

    result_configuration {
      output_location = "s3://${module.athena_results_bucket.name}/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

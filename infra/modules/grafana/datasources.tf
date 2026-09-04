# Data sources are provisioned from a file Grafana reads at start up. The
# file is rendered here and written into the container by its command, see
# ecs.tf. All of them authenticate with the task role.
locals {
  aws_datasource_json_data = {
    authType      = "default"
    defaultRegion = data.aws_region.current.region
  }

  datasources = concat(
    [
      {
        name      = "CloudWatch"
        uid       = "cloudwatch"
        type      = "cloudwatch"
        access    = "proxy"
        isDefault = true
        editable  = false
        jsonData  = local.aws_datasource_json_data
      },
      {
        name     = "X-Ray"
        uid      = "xray"
        type     = "grafana-x-ray-datasource"
        access   = "proxy"
        editable = false
        jsonData = local.aws_datasource_json_data
      }
    ],
    local.submission_events_enabled ? [
      {
        name     = "Athena"
        uid      = "athena"
        type     = "grafana-athena-datasource"
        access   = "proxy"
        editable = false
        jsonData = merge(local.aws_datasource_json_data, {
          catalog        = "s3tablescatalog/${var.submission_events_table_bucket_name}"
          database       = "forms"
          workgroup      = aws_athena_workgroup.grafana.name
          outputLocation = "s3://${module.athena_results_bucket.name}/"
        })
      }
    ] : []
  )

  datasources_yaml = yamlencode({
    apiVersion  = 1
    datasources = local.datasources
  })
}

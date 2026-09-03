locals {
  managed_grafana_count = var.environmental_settings.enable_managed_grafana ? 1 : 0
}

data "aws_iam_policy_document" "grafana_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["grafana.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "grafana" {
  count = local.managed_grafana_count

  name               = "${var.environment_name}-grafana-workspace"
  assume_role_policy = data.aws_iam_policy_document.grafana_assume_role.json
}

resource "aws_iam_role_policy_attachment" "grafana" {
  for_each = var.environmental_settings.enable_managed_grafana ? toset([
    "arn:aws:iam::aws:policy/service-role/AmazonGrafanaCloudWatchAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonGrafanaAthenaAccess",
    "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess",
  ]) : toset([])

  role       = aws_iam_role.grafana[0].name
  policy_arn = each.value
}

resource "aws_grafana_workspace" "this" {
  count = local.managed_grafana_count

  name                     = "${var.environment_name}-forms"
  description              = "GOV.UK Forms ${var.environment_name} observability"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.grafana[0].arn
  data_sources             = ["ATHENA", "CLOUDWATCH", "XRAY"]
  grafana_version          = "12.4"

  depends_on = [aws_iam_role_policy_attachment.grafana]
}

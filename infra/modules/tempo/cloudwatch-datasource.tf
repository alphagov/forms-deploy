# Read-only access for Grafana's CloudWatch datasource (docker/grafana/datasources.yaml)
# - metrics, Logs Insights, and Application Signals (SLO burn-rate data).
# Uses the task's own IAM role rather than access keys (authType: default
# in the datasource config), same mechanism as everything else in this
# module. Query-only: no new ingestion/storage cost, only CloudWatch API
# request cost (metrics) and per-GB-scanned cost (Logs Insights).
data "aws_iam_policy_document" "cloudwatch_datasource_access" {
  statement {
    sid    = "CloudWatchMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:GetMetricData",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:DescribeAlarms",
      "tag:GetResources",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudWatchLogsInsights"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetQueryResults",
      "logs:StartQuery",
      "logs:StopQuery",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ApplicationSignals"
    effect = "Allow"
    actions = [
      "application-signals:Get*",
      "application-signals:List*",
    ]
    resources = ["*"]
  }

  statement {
    # Grafana calls this to resolve account context when building a Logs
    # Insights query (GET .../resources/accounts) - not optional, without
    # it log queries in Explore come back as "no data". See the oam VPC
    # endpoint in infra/modules/environment/endpoints.tf.
    sid    = "CrossAccountObservability"
    effect = "Allow"
    actions = [
      "oam:ListSinks",
      "oam:ListAttachedLinks",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch_datasource_access" {
  name   = "${var.env_name}-tempo-cloudwatch-datasource-access"
  policy = data.aws_iam_policy_document.cloudwatch_datasource_access.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_datasource_access" {
  role       = aws_iam_role.tempo_task.name
  policy_arn = aws_iam_policy.cloudwatch_datasource_access.arn
}

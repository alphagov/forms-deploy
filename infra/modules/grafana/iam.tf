locals {
  submission_events_enabled = var.submission_events_table_bucket_name != null

  submission_events_table_bucket_arn = local.submission_events_enabled ? "arn:aws:s3tables:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:bucket/${var.submission_events_table_bucket_name}" : null

  # Databases and tables in the federated catalog have the catalog path
  # embedded in their ARNs, see infra/modules/submission-events/iam.tf
  submission_events_glue_arns = local.submission_events_enabled ? [
    "arn:aws:glue:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:catalog",
    "arn:aws:glue:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:catalog/s3tablescatalog",
    "arn:aws:glue:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:catalog/s3tablescatalog/${var.submission_events_table_bucket_name}",
    "arn:aws:glue:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:database/s3tablescatalog/${var.submission_events_table_bucket_name}/*",
    "arn:aws:glue:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:table/s3tablescatalog/${var.submission_events_table_bucket_name}/*"
  ] : []
}

##
# Task role: what Grafana itself may do
##
resource "aws_iam_role" "task" {
  name               = "${local.name}-ecs-task"
  description        = "Used by Grafana tasks when running"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    sid     = "AllowECS"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "task" {
  #checkov:skip=CKV_AWS_355:CloudWatch, X-Ray and Athena catalog read operations cannot be scoped to specific resources
  #checkov:skip=CKV_AWS_356:CloudWatch, X-Ray and Athena catalog read operations cannot be scoped to specific resources
  name   = "${local.name}-ecs-task-policy"
  policy = data.aws_iam_policy_document.task.json
}

resource "aws_iam_role_policy_attachment" "task" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.task.arn
}

data "aws_iam_policy_document" "task" {
  #checkov:skip=CKV_AWS_356:"*" is necessary here, and all of the actions are read-only.

  # https://grafana.com/docs/grafana/latest/datasources/aws-cloudwatch/configure/
  statement {
    sid    = "ReadCloudWatchMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetInsightRuleReport",
      "pi:GetResourceMetrics"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ReadCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:ListAggregateLogGroupSummaries",
      "logs:GetLogGroupFields",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ReadResourceMetadataForDataSources"
    effect = "Allow"
    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "tag:GetResources",
      "oam:ListSinks",
      "oam:ListAttachedLinks"
    ]
    resources = ["*"]
  }

  # https://grafana.com/docs/plugins/grafana-x-ray-datasource/latest/configure/
  statement {
    sid    = "ReadXRayAndApplicationSignals"
    effect = "Allow"
    actions = [
      "xray:BatchGetTraces",
      "xray:GetTraceSummaries",
      "xray:GetTraceGraph",
      "xray:GetGroups",
      "xray:GetTimeSeriesServiceStatistics",
      "xray:GetInsightSummaries",
      "xray:GetInsight",
      "xray:GetServiceGraph",
      "xray:GetSamplingRules",
      "application-signals:ListServices",
      "application-signals:ListServiceOperations",
      "application-signals:ListServiceDependencies",
      "application-signals:ListServiceLevelObjectives",
      "application-signals:GetService",
      "application-signals:GetServiceLevelObjective"
    ]
    resources = ["*"]
  }

  # https://grafana.com/docs/plugins/grafana-athena-datasource/latest/configure/
  statement {
    sid    = "BrowseAthenaCatalogs"
    effect = "Allow"
    actions = [
      "athena:ListWorkGroups",
      "athena:ListDataCatalogs",
      "athena:GetDataCatalog",
      "athena:ListDatabases",
      "athena:GetDatabase",
      "athena:ListTableMetadata",
      "athena:GetTableMetadata"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "RunAthenaQueriesInGrafanaWorkgroup"
    effect = "Allow"
    actions = [
      "athena:GetWorkGroup",
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetQueryResultsStream"
    ]
    resources = [aws_athena_workgroup.grafana.arn]
  }

  statement {
    sid    = "ReadAndWriteAthenaQueryResults"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:GetObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      module.athena_results_bucket.arn,
      "${module.athena_results_bucket.arn}/*"
    ]
  }

  dynamic "statement" {
    for_each = local.submission_events_enabled ? [1] : []

    content {
      sid    = "ReadSubmissionEventsThroughGlueCatalog"
      effect = "Allow"
      actions = [
        "glue:GetCatalog",
        "glue:GetCatalogs",
        "glue:GetDatabase",
        "glue:GetDatabases",
        "glue:GetTable",
        "glue:GetTables",
        "glue:GetPartition",
        "glue:GetPartitions",
        "glue:BatchGetPartition"
      ]
      resources = local.submission_events_glue_arns
    }
  }

  dynamic "statement" {
    for_each = local.submission_events_enabled ? [1] : []

    content {
      sid    = "ReadSubmissionEventsTableData"
      effect = "Allow"
      actions = [
        "s3tables:GetTableBucket",
        "s3tables:ListNamespaces",
        "s3tables:GetNamespace",
        "s3tables:ListTables",
        "s3tables:GetTable",
        "s3tables:GetTableData",
        "s3tables:GetTableMetadataLocation"
      ]
      resources = [
        local.submission_events_table_bucket_arn,
        "${local.submission_events_table_bucket_arn}/table/*"
      ]
    }
  }

  dynamic "statement" {
    for_each = local.submission_events_enabled ? [1] : []

    content {
      # Athena vends credentials for federated catalogs through Lake Formation
      sid       = "VendCredentialsForFederatedCatalog"
      effect    = "Allow"
      actions   = ["lakeformation:GetDataAccess"]
      resources = ["*"]
    }
  }
}

##
# Execution role: what ECS needs to start the task
##
resource "aws_iam_role" "task_execution" {
  name               = "${local.name}-ecs-task-execution"
  description        = "Used by ECS to create Grafana tasks"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "task_execution_standard" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "task_execution_additional" {
  name   = "${local.name}-ecs-task-execution-additional"
  policy = data.aws_iam_policy_document.task_execution_additional.json
}

resource "aws_iam_role_policy_attachment" "task_execution_additional" {
  role       = aws_iam_role.task_execution.name
  policy_arn = aws_iam_policy.task_execution_additional.arn
}

data "aws_iam_policy_document" "task_execution_additional" {
  statement {
    sid     = "ReadSecrets"
    effect  = "Allow"
    actions = ["ssm:GetParameters"]
    resources = [
      aws_ssm_parameter.database_password.arn,
      aws_ssm_parameter.admin_password.arn,
      aws_ssm_parameter.secret_key.arn,
      aws_ssm_parameter.github_client_id.arn,
      aws_ssm_parameter.github_client_secret.arn
    ]
  }
}

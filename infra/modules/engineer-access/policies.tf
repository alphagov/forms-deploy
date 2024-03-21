data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  codestar_connection = {
    "619109835131" = "6d5b8a26-b0d3-41da-ae2f-11a5f805bc3c" #user-research
    "498160065950" = "9dcd616c-3f7d-4f20-8a6b-8fca788e674b" #dev
    "972536609845" = "de05d028-2cbd-4d06-8946-0e4aca60f4ca" #staging
    "443944947292" = "c253c931-651d-4d48-950a-c1ac2dfd7ca8" #production
    "711966560482" = "8ad08da2-743c-4431-bee6-ad1ae9efebe7" #deploy
  }
}

resource "aws_iam_policy" "manage_deployments" {
  #checkov:skip=CKV_AWS_111: allow write access without constraint when needed
  #checkov:skip=CKV_AWS_290: allow write access without constraint when needed
  #checkov:skip=CKV_AWS_289: allow permissions management (PassRole) without constraint when needed
  #checkov:skip=CKV_AWS_355: allow resource * when needed

  name        = "manage-deployments"
  path        = "/"
  description = "Permission to manage deployements via CodePipeline"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PassRole"
        Action = [
          "iam:GetRole",
          "iam:PassRole",
          "codestar-connections:PassConnection"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "DisableEnableMainBranchDeploymentToAnyEnvironment"
        Action = [
          "codepipeline:DisableStageTransition",
          "codepipeline:EnableStageTransition",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:codepipeline:eu-west-2:${local.account_id}:*",
        ]
      },
      {
        Sid = "CodePipelineStartStopRetry"
        Action = [
          "codepipeline:RetryStageExecution",
          "codepipeline:StartPipelineExecution",
          "codepipeline:StopPipelineExecution",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "CodePipelineModifyDevBranches"
        Action = [
          "codepipeline:UpdatePipeline",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:codepipeline:eu-west-2:${local.account_id}:*"
        ]
      },
      {
        Sid = "CodeStarConnection"
        Action = [
          "codestar-connections:UseConnection",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:codestar-connections:eu-west-2:${local.account_id}:connection/${lookup(local.codestar_connection, local.account_id)}"
      },
    ]
  })
}

resource "aws_iam_policy" "query_rds_with_data_api" {
  count       = var.env_name != "deploy" ? 1 : 0
  name        = "query-rds-with-data-api"
  path        = "/"
  description = "Permission to use the data api to query RDS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "DataApi"
        Action = [
          "rds-data:ExecuteStatement",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:rds:eu-west-2:${local.account_id}:cluster:aurora-cluster-*"
      },
      {
        Sid = "SecretsManager"
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:secretsmanager:eu-west-2:${local.account_id}:secret:rds-db-credentials/*/forms-api-app/*",
          "arn:aws:secretsmanager:eu-west-2:${local.account_id}:secret:rds-db-credentials/*/forms-admin-app/*"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "run_task" {
  count       = var.env_name != "deploy" ? 1 : 0
  name        = "run-task"
  path        = "/"
  description = "Permission to run task on ECS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:RunTask",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ecs:eu-west-2:${local.account_id}:task-definition/*_forms-admin",
          "arn:aws:ecs:eu-west-2:${local.account_id}:task-definition/*_forms-api",
          "arn:aws:ecs:eu-west-2:${local.account_id}:task-definition/*_forms-admin:*",
          "arn:aws:ecs:eu-west-2:${local.account_id}:task-definition/*_forms-api:*",
        ]
      },
      {
        Action = [
          "iam:PassRole",
        ],
        Effect = "Allow"
        Resource = [
          "arn:aws:iam::${local.account_id}:role/*-forms-admin-ecs-task",
          "arn:aws:iam::${local.account_id}:role/*-forms-admin-ecs-task-execution",
          "arn:aws:iam::${local.account_id}:role/*-forms-api-ecs-task",
          "arn:aws:iam::${local.account_id}:role/*-forms-api-ecs-task-execution",
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "stop_task" {
  count       = var.env_name != "deploy" ? 1 : 0
  name        = "stop-task"
  path        = "/"
  description = "Permission to stop task on ECS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:StopTask",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ecs:eu-west-2:${local.account_id}:task/forms-*/*",
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "manage_parameter_store" {
  #checkov:skip=CKV_AWS_290:We have additional restrictions elsewhere
  name        = "manage-parameter-store"
  path        = "/"
  description = "Permission to create, delete and modify parameter store values"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:PutParameter",
          "ssm:DeleteParameter",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Action = [
          "ssm:PutParameter",
          "ssm:DeleteParameter",
        ]
        Effect = "Deny"
        Resource = [
          "arn:aws:ssm:*:*:parameter/database/master-password"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "manage_dashboards" {
  #checkov:skip=CKV_AWS_290: We're OK with unlimited access to CloudWatch dashboards
  #checkov:skip=CKV_AWS_355: We're OK with unlimited access to CloudWatch dashboards
  name        = "manage-dashboards"
  path        = "/"
  description = "Create, update and delete CloudWatch dashbaords"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:PutDashboard",
          "cloudwatch:DeleteDashboards"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_policy" "deny_parameter_store" {
  name        = "deny-parameter-store-read-access"
  path        = "/"
  description = "Deny viewing secrets in parameter store"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter*",
        ]
        Effect   = "Deny"
        Resource = ["*"]
      }
    ]
  })
}
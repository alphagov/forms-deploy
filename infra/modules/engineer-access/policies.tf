data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_policy" "manage_deployments" {
  count = var.env_name == "deploy" ? 1 : 0

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
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-admin-main-branch/*",
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-api-main-branch/*",
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-runner-main-branch/*",
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
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-admin-dev-dev-branches",
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-admin-user-research-dev-branches",
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-api-dev-dev-branches",
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-api-user-research-dev-branches",
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-runner-dev-dev-branches",
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-runner-user-research-dev-branches",
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-admin-dev-dev-branches/*",
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-admin-user-research-dev-branches/*",
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-api-dev-dev-branches/*",
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-api-user-research-dev-branches/*",
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-runner-dev-dev-branches/*",
          "arn:aws:codepipeline:eu-west-2:711966560482:forms-runner-user-research-dev-branches/*",
        ]
      },
      {
        Sid = "CodeStarConnection"
        Action = [
          "codestar-connections:UseConnection",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"
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

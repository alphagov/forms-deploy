data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
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
        Resource = var.codestar_connection_arn
      },
    ]
  })
}

resource "aws_iam_policy" "query_rds_with_data_api" {
  count       = var.allow_rds_data_api_access ? 1 : 0
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
          "arn:aws:secretsmanager:eu-west-2:${local.account_id}:secret:rds-db-credentials/*/forms-admin-app/*",
          "arn:aws:secretsmanager:eu-west-2:${local.account_id}:secret:rds-db-credentials/*/forms-runner-app/*"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "run_task" {
  count       = var.allow_ecs_task_usage ? 1 : 0
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
  count       = var.allow_ecs_task_usage ? 1 : 0
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
          "arn:aws:ssm:*:*:parameter/${var.env_name}/database/root-password"
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

resource "aws_iam_policy" "manage_maintenance_page" {
  name        = "manage-maintenance-page"
  path        = "/"
  description = "Permission to manage maintenance page"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:DeregisterTaskDefinition",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:TagResource"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ecs:eu-west-2:${local.account_id}:task-definition/${var.env_name}_forms-admin:*",
          "arn:aws:ecs:eu-west-2:${local.account_id}:task-definition/${var.env_name}_forms-runner:*"
        ]
      },
      {
        Action = [
          "ecs:UpdateService"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ecs:eu-west-2:${local.account_id}:service/forms-${var.env_name}/forms-admin",
          "arn:aws:ecs:eu-west-2:${local.account_id}:service/forms-${var.env_name}/forms-runner"
        ]
      },
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::gds-forms-${var.environment_type}-tfstate",
          "arn:aws:s3:::gds-forms-${var.environment_type}-tfstate/*"
        ]
      },
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

resource "aws_iam_policy" "lock_state_files" {
  name = "lock-state-files"
  path = "/"

  description = "Allow reading and writing from a DynamoDB table used for Terraform state file locking"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [var.dynamodb_state_file_locks_table_arn]
      }
    ]
  })
}
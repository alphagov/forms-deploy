data "aws_iam_policy_document" "ecs_service" {
  source_policy_documents = [
    data.aws_iam_policy_document.ecs.json,
    data.aws_iam_policy_document.alb.json,
    data.aws_iam_policy_document.autoscaling.json,
    data.aws_iam_policy_document.logs.json,
  ]
}

resource "aws_iam_policy" "ecs_service" {
  policy = data.aws_iam_policy_document.ecs_service.json
}

resource "aws_iam_role_policy_attachment" "ecs_service" {
  policy_arn = aws_iam_policy.ecs_service.arn
  role       = aws_iam_role.deployer.id
}

data "aws_iam_policy_document" "ecs" {
  #checkov:skip=CKV_AWS_111: allow write access without constraint when needed
  #checkov:skip=CKV_AWS_356: allow resource * when needed

  statement {
    sid = "ManageS3"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::gds-forms-${var.environment_type}-tfstate/*",
      "arn:aws:s3:::gds-forms-${var.environment_type}-tfstate",
    ]
    effect = "Allow"
  }

  statement {
    sid = "ReleaseTerraformStateLock"
    actions = [
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::gds-forms-${var.environment_type}-tfstate/*.tflock"
    ]
    effect = "Allow"
  }

  statement {
    sid = "DescribeECSClustersAndServices"
    actions = [
      "ecs:Describe*",
      "ecs:List*",
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid = "ManageECSClustersAndServices"
    actions = [
      "ecs:*Cluster",
      "ecs:*Service",
      "ecs:TagResource",
      "ecs:UntagResource",
      "ecs:ListTagsForResource",
    ]
    resources = ["arn:aws:ecs:eu-west-2:${var.account_id}:*"]
    effect    = "Allow"
  }

  statement {
    sid = "ManageEcsTaskDefinitions"
    actions = [
      "ecs:*TaskDefinition",
      "ecs:*TaskSet",
      "ecs:RunTask",
      "ecs:DescribeTasks"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid = "ManageTaskAndTaskExecutionRoles"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PassRole",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:UpdateAssumeRolePolicy",
      "iam:TagRole"
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:role/${var.environment_name}-forms-admin-ecs-task",
      "arn:aws:iam::${var.account_id}:role/${var.environment_name}-forms-runner-ecs-task",
      "arn:aws:iam::${var.account_id}:role/${var.environment_name}-forms-product-page-ecs-task",
      "arn:aws:iam::${var.account_id}:role/${var.environment_name}-forms-admin-ecs-task-execution",
      "arn:aws:iam::${var.account_id}:role/${var.environment_name}-forms-runner-ecs-task-execution",
      "arn:aws:iam::${var.account_id}:role/${var.environment_name}-forms-product-page-ecs-task-execution",
      "arn:aws:iam::${var.account_id}:role/${var.environment_name}-forms-runner-queue-worker-ecs-task-execution"
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageEcsExecutionPolicies"
    actions = [
      "iam:*Policy",
      "iam:*PolicyVersion",
      "iam:*PolicyVersions",
      "iam:*RolePolicy",
      "iam:*AssumeRolePolicy"
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:policy/${var.environment_name}-forms-admin-ecs-task-execution-additional",
      "arn:aws:iam::${var.account_id}:policy/${var.environment_name}-forms-runner-ecs-task-execution-additional",
      "arn:aws:iam::${var.account_id}:policy/${var.environment_name}-forms-product-page-ecs-task-execution-additional",
      "arn:aws:iam::${var.account_id}:policy/${var.environment_name}-forms-runner-queue-worker-ecs-task-execution-additional"
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageEcsTaskPolicies"
    actions = [
      "iam:*Policy",
      "iam:*PolicyVersion",
      "iam:*PolicyVersions",
      "iam:*RolePolicy",
      "iam:*AssumeRolePolicy"
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:policy/${var.environment_name}-forms-admin-ecs-task-policy",
      "arn:aws:iam::${var.account_id}:policy/${var.environment_name}-forms-admin-adot-collector",
      "arn:aws:iam::${var.account_id}:policy/${var.environment_name}-forms-runner-ecs-task-policy",
      "arn:aws:iam::${var.account_id}:policy/${var.environment_name}-forms-runner-adot-collector",
      "arn:aws:iam::${var.account_id}:policy/${var.environment_name}-forms-product-page-ecs-task-policy",
      "arn:aws:iam::${var.account_id}:policy/${var.environment_name}-forms-product-page-adot-collector"
    ]
    effect = "Allow"
  }


  statement {
    sid = "ManageSecurityGroups"
    actions = [
      "ec2:*SecurityGroup*",
    ]
    resources = [
      "arn:aws:ec2:eu-west-2:${var.account_id}:*/*"
    ]
    effect = "Allow"
  }

  statement {
    sid = "DescribeEC2"
    actions = [
      "ec2:Describe*"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageEC2Tags"
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:aws:ec2:eu-west-2:${var.account_id}:*/*"
    ]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "alb" {
  #checkov:skip=CKV_AWS_111: allow write access without constraint when needed
  #checkov:skip=CKV_AWS_356: allow resource * when needed

  statement {
    sid = "ManageAlb"
    actions = [
      "elasticloadbalancing:*Tags",
      "elasticloadbalancing:*TargetGroup*",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:*Listener",
      "elasticloadbalancing:*Rule*",
      "elasticloadbalancing:*LoadBalancer*",
      "elasticloadbalancing:SetWebACL",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:eu-west-2:${var.account_id}:*"
    ]
    effect = "Allow"
  }

  statement {
    sid = "ListAlbResources"
    actions = [
      "elasticloadbalancing:Describe*",
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "autoscaling" {
  #checkov:skip=CKV_AWS_111: allow write access without constraint when needed
  #checkov:skip=CKV_AWS_356: allow resource * when needed

  statement {
    sid = "ManageApplicationAutoScaling"
    actions = [
      "application-autoscaling:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid = "ManageServiceLinkedRoleForAutoscaling"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = ["arn:aws:iam::*:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
    ]
    effect = "Allow"
    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["ecs.application-autoscaling.amazonaws.com"]
    }
  }

  statement {
    sid = "AllowPassingServiceLinkedRole"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageCloudWatchAlarms"
    actions = [
      "cloudwatch:*Alarms",
      "cloudwatch:*Alarm",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:TagResource"
    ]
    resources = [
      "arn:aws:cloudwatch:eu-west-2:${var.account_id}:*",
      "arn:aws:cloudwatch:us-east-1:${var.account_id}:*",
    ]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "logs" {
  #checkov:skip=CKV_AWS_111: allow write access without constraint when needed
  #checkov:skip=CKV_AWS_356: allow resource * when needed
  statement {
    sid = "CreateLogs"
    actions = [
      "logs:*LogEvents",
      "logs:*LogStream",
      "logs:*SubscriptionFilters",
      "logs:*SubscriptionFilter",
      "logs:*LogGroup"
    ]
    resources = [
      "arn:aws:logs:eu-west-2:${var.account_id}:log-group:/aws/ecs/forms-admin-${var.environment_name}:*",
      "arn:aws:logs:eu-west-2:${var.account_id}:log-group:/aws/ecs/forms-admin-${var.environment_name}/adot-collector:*",
      "arn:aws:logs:eu-west-2:${var.account_id}:log-group:/aws/ecs/forms-runner-${var.environment_name}:*",
      "arn:aws:logs:eu-west-2:${var.account_id}:log-group:/aws/ecs/forms-runner-${var.environment_name}/adot-collector:*",
      "arn:aws:logs:eu-west-2:${var.account_id}:log-group:/aws/ecs/forms-runner-queue-worker-${var.environment_name}:*",
      "arn:aws:logs:eu-west-2:${var.account_id}:log-group:/aws/ecs/forms-runner-queue-worker-${var.environment_name}/adot-collector:*",
      "arn:aws:logs:eu-west-2:${var.account_id}:log-group:/aws/ecs/forms-product-page-${var.environment_name}:*",
      "arn:aws:logs:eu-west-2:${var.account_id}:log-group:/aws/ecs/forms-product-page-${var.environment_name}/adot-collector:*",
    ]
    effect = "Allow"
  }

  statement {
    sid = "DescribeLogGroups"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
  }
}

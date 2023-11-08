data "aws_iam_policy_document" "deployer" {
  #checkov:skip=CKV_AWS_111: allow write access without constraint when needed
  #checkov:skip=CKV_AWS_356: allow resource * when needed
  statement {
    sid = "CreateLogs"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeSubscriptionFilters",
      "logs:PutSubscriptionFilter",
      "logs:DeleteSubscriptionFilter",
      "logs:ListTagsLogGroup"
    ]
    resources = [
      "arn:aws:logs:eu-west-2:${lookup(local.account_ids, var.env_name)}:log-group:forms-admin-${var.env_name}:*",
      "arn:aws:logs:eu-west-2:${lookup(local.account_ids, var.env_name)}:log-group:forms-api-${var.env_name}:*",
      "arn:aws:logs:eu-west-2:${lookup(local.account_ids, var.env_name)}:log-group:forms-runner-${var.env_name}:*",
      "arn:aws:logs:eu-west-2:${lookup(local.account_ids, var.env_name)}:log-group:forms-product-page-${var.env_name}:*"
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

  statement {
    sid = "ManageS3"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::gds-forms-${var.env_name != "dev" ? var.env_name : "development"}-tfstate/*",
      "arn:aws:s3:::gds-forms-${var.env_name != "dev" ? var.env_name : "development"}-tfstate",
    ]
    effect = "Allow"
  }

  statement {
    sid = "CreateEcsClusters"
    actions = [
      "ecs:DescribeClusters",
      "ecs:DescribeServices"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid = "ManageEcs"
    actions = [
      "ecs:CreateCluster",
      "ecs:DeleteCluster",
      "ecs:UpdateCluster",
      "ecs:CreateService",
      "ecs:DeleteService",
      "ecs:UpdateService",
      "ecs:TagResource",
      "ecs:UntagResource",
      "ecs:ListTagsForResource"
    ]
    resources = ["arn:aws:ecs:eu-west-2:${lookup(local.account_ids, var.env_name)}:*"]
    effect    = "Allow"
  }

  statement {
    sid = "ManageEcsTaskDefinitions"
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:CreateTaskSet",
      "ecs:DeleteTaskSet",
      "ecs:DescribeTaskSets",
      "ecs:UpdateServicePrimaryTaskSet",
      "ecs:UpdateTaskSet",
      "ecs:RunTask"
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
      "iam:ListAttachedRolePolicies"
    ]
    resources = [
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/${var.env_name}-forms-admin-ecs-task",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/${var.env_name}-forms-api-ecs-task",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/${var.env_name}-forms-runner-ecs-task",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/${var.env_name}-forms-product-page-ecs-task",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/${var.env_name}-forms-admin-ecs-task-execution",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/${var.env_name}-forms-api-ecs-task-execution",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/${var.env_name}-forms-runner-ecs-task-execution",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/${var.env_name}-forms-product-page-ecs-task-execution"
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageEcsExecutionPolicies"
    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:GetRolePolicy",
      "iam:GetPolicy",
      "iam:TagPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion"
    ]
    resources = [
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:policy/${var.env_name}-forms-admin-ecs-task-execution-additional",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:policy/${var.env_name}-forms-api-ecs-task-execution-additional",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:policy/${var.env_name}-forms-runner-ecs-task-execution-additional",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:policy/${var.env_name}-forms-product-page-ecs-task-execution-additional"
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageEcsTaskPolicies"
    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:GetRolePolicy",
      "iam:GetPolicy",
      "iam:TagPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion"
    ]
    resources = [
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:policy/${var.env_name}-forms-admin-ecs-task-policy",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:policy/${var.env_name}-forms-api-ecs-task-policy",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:policy/${var.env_name}-forms-runner-ecs-task-policy",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:policy/${var.env_name}-forms-product-page-ecs-task-policy"
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageAlb"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancerListeners",
      "elasticloadbalancing:DeleteLoadBalancerListeners",
      "elasticloadbalancing:DescribeLoadBalancerListeners",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyTargetGroupAttributes"
    ]
    resources = [
      "arn:aws:elasticloadbalancing:eu-west-2:${lookup(local.account_ids, var.env_name)}:*"
    ]
    effect = "Allow"
  }

  statement {
    sid = "ListAlbResources"
    actions = [
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeTags"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageSecurityGroups"
    actions = [
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:ModifySecurityGroupRules",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
      "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
    ]
    resources = [
      "arn:aws:ec2:eu-west-2:${lookup(local.account_ids, var.env_name)}:*/*"
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
    sid = "DescribeElasticache"
    actions = [
      "elasticache:DescribeReplicationGroups"
    ]
    resources = [
      "arn:aws:elasticache:eu-west-2:${lookup(local.account_ids, var.env_name)}:replicationgroup:forms-runner-${var.env_name}"
    ]
    effect = "Allow"
  }
}

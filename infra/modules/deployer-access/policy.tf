resource "aws_iam_policy" "ecs" {
  policy = data.aws_iam_policy_document.ecs.json
}

resource "aws_iam_role_policy_attachment" "ecs" {
  policy_arn = aws_iam_policy.ecs.arn
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

resource "aws_iam_policy" "alb" {
  policy = data.aws_iam_policy_document.alb.json
}

resource "aws_iam_role_policy_attachment" "alb" {
  policy_arn = aws_iam_policy.alb.arn
  role       = aws_iam_role.deployer.id
}

data "aws_iam_policy_document" "alb" {
  #checkov:skip=CKV_AWS_111: allow write access without constraint when needed
  #checkov:skip=CKV_AWS_356: allow resource * when needed

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
}

resource "aws_iam_policy" "autoscaling" {
  policy = data.aws_iam_policy_document.autoscaling.json
}

resource "aws_iam_role_policy_attachment" "autoscaling" {
  policy_arn = aws_iam_policy.autoscaling.arn
  role       = aws_iam_role.deployer.id
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
      "cloudwatch:ListTagsForResource"
    ]
    resources = ["arn:aws:cloudwatch:eu-west-2:${local.account_ids[var.env_name]}:*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "logs" {
  policy = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_role_policy_attachment" "logs" {
  policy_arn = aws_iam_policy.logs.arn
  role       = aws_iam_role.deployer.id
}

data "aws_iam_policy_document" "logs" {
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
}

# One policy per module
resource "aws_iam_policy" "redis" {
  policy = data.aws_iam_policy_document.redis.json
}

resource "aws_iam_role_policy_attachment" "redis" {
  policy_arn = aws_iam_policy.redis.arn
  role       = aws_iam_role.deployer.id
}

data "aws_iam_policy_document" "redis" {
  statement {
    sid = "ManageElasticacheClusters"
    actions = [
      "elasticache:DescribeCacheClusters"
    ]
    resources = [
      "arn:aws:elasticache:eu-west-2:${lookup(local.account_ids, var.env_name)}:cluster:forms-runner-${var.env_name}-*",
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageElasticacheReplicationGroups"
    actions = [
      "elasticache:AddTagsToResource",
      "elasticache:CreateReplicationGroup",
      "elasticache:DeleteReplicationGroup",
      "elasticache:DescribeReplicationGroups",
      "elasticache:ListTagsForResource",
      "elasticache:ModifyReplicationGroup",
    ]
    resources = [
      "arn:aws:elasticache:eu-west-2:${lookup(local.account_ids, var.env_name)}:replicationgroup:forms-runner-${var.env_name}",
    ]
  }

  statement {
    sid = "DescribeElasticacheParameterGroups"
    actions = [
      "elasticache:DescribeCacheParameterGroups",
    ]
    resources = [
      "arn:aws:elasticache:eu-west-2:${lookup(local.account_ids, var.env_name)}:parametergroup:*",
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageElasticacheParameterGroup"
    actions = [
      "elasticache:AddTagsToResource",
      "elasticache:CreateCacheParameterGroup",
      "elasticache:DeleteCacheParameterGroup",
      "elasticache:DescribeCacheParameters",
      "elasticache:ListTagsForResource",
      "elasticache:ModifyCacheParameterGroup",
    ]
    resources = [
      "arn:aws:elasticache:eu-west-2:${lookup(local.account_ids, var.env_name)}:parametergroup:forms-runner-*",
    ]
    effect = "Allow"
  }

  statement {
    sid = "DescribeElasticacheSubnetGroups"
    actions = [
      "elasticache:DescribeCacheSubnetGroups",
    ]
    resources = [
      "arn:aws:elasticache:eu-west-2:${lookup(local.account_ids, var.env_name)}:subnetgroup:*",
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageElasticacheSubnetGroups"
    actions = [
      "elasticache:AddTagsToResource",
      "elasticache:CreateCacheSubnetGroup",
      "elasticache:DeleteCacheSubnetGroup",
      "elasticache:ListTagsForResource",
      "elasticache:ModifyCacheSubnetGroup",
    ]
    resources = [
      "arn:aws:elasticache:eu-west-2:${lookup(local.account_ids, var.env_name)}:subnetgroup:redis-${var.env_name}",
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageElasticacheSecurityGroups"
    actions = [
      "elasticache:AddTagsToResource",
      "elasticache:AuthorizeCacheSecurityGroupIngress",
      "elasticache:CreateCacheSecurityGroup",
      "elasticache:DeleteCacheSecurityGroup",
      "elasticache:DescribeCacheSecurityGroups",
      "elasticache:ListTagsForResource",
      "elasticache:RevokeCacheSecurityGroupIngress",
    ]
    resources = [
      "arn:aws:elasticache:eu-west-2:${lookup(local.account_ids, var.env_name)}:securitygroup:forms-runner-redis",
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "alerts" {
  policy = data.aws_iam_policy_document.alerts.json
}

resource "aws_iam_role_policy_attachment" "alerts" {
  policy_arn = aws_iam_policy.alerts.arn
  role       = aws_iam_role.deployer.id
}

data "aws_iam_policy_document" "alerts" {
  statement {
    sid = "ManageKMSKeys"
    actions = [
      "kms:CreateKey",
      "kms:DescribeKey",
      "kms:EnableKeyRotation",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListResourceTags",
      "kms:PutKeyPolicy",
      "kms:TagResource",
      "kms:UntagResource",
    ]
    resources = [
      # TODO: be more specific?
      "arn:aws:kms:eu-west-2:${lookup(local.account_ids, var.env_name)}:key/*",
    ]
    effect = "Allow"
  }

  statement {
    sid = "DescribeSSMParameters"
    actions = [
      "ssm:DescribeParameters",
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}:*"
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageSSMParameters"
    actions = [
      "ssm:AddTagsToResource",
      "ssm:DeleteParameter",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListTagsForResource",
      "ssm:PutParameter",
      "ssm:RemoveTagsFromResource",
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}:parameter/alerting/${var.env_name}/pager-duty-integration-url",
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageSNS"
    actions = [
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:GetTopicAttributes",
      "sns:GetSubscriptionAttributes",
      "sns:ListTagsForResource",
      "sns:Subscribe",
      "sns:TagResource",
      "sns:Unsubscribe",
      "sns:UntagResource",
    ]
    resources = [
      "arn:aws:sns:eu-west-2:${lookup(local.account_ids, var.env_name)}:pager_duty_integration_${var.env_name}",
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageCloudwatchMetricAlarms"
    actions = [
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:EnableAlarmActions",
      "cloudwatch:GetMetricData",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:TagResource",
      "cloudwatch:UntagResource",
    ]
    resources = [
      "arn:aws:cloudwatch:eu-west-2:${lookup(local.account_ids, var.env_name)}:alarm:alb_healthy_host_count_*",

    ]
    effect = "Allow"
  }


}
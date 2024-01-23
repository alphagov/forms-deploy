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
    resources = ["arn:aws:ecs:eu-west-2:${lookup(local.account_ids, var.env_name)}:*"]
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
      "ec2:*SecurityGroup*",
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
      "elasticloadbalancing:*Tags",
      "elasticloadbalancing:*TargetGroup*",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:*Listener",
      "elasticloadbalancing:*Rule*",
      "elasticloadbalancing:*LoadBalancer*",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:eu-west-2:${lookup(local.account_ids, var.env_name)}:*"
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
      "logs:*LogEvents",
      "logs:*LogStream",
      "logs:*SubscriptionFilters",
      "logs:*LogGroup"
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

# One policy document per root
data "aws_iam_policy_document" "redis" {
  statement {
    sid = "ManageElasticache"
    actions = [
      "elasticache:*CacheCluster*",
      "elasticache:*CacheParameter*",
      "elasticache:*CacheSubnetGroup*",
      "elasticache:*CacheSecurityGroup*",
      "elasticache:*ReplicationGroup*",
      "elasticache:*Tags*",
    ]
    resources = [
      "arn:aws:elasticache:eu-west-2:${lookup(local.account_ids, var.env_name)}:*",
    ]
  }
}

data "aws_iam_policy_document" "alerts" {
  statement {
    sid = "ManageKMSKeyAlerts"
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
      "sns:*Topic*",
      "sns:GetSubscriptionAttributes",
      "sns:*Tag*",
      "sns:*Subscrib*",
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
      "cloudwatch:*Alarm*",
      "cloudwatch:*Metric*",
      "cloudwatch:TagResource",
      "cloudwatch:UntagResource",
    ]
    resources = [
      "arn:aws:cloudwatch:eu-west-2:${lookup(local.account_ids, var.env_name)}:alarm:alb_healthy_host_count_*",

    ]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "auth0" {
  statement {
    sid = "ManageSSMParametersAuth0"
    actions = [
      "ssm:*Tag*",
      "ssm:*Parameter*",
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}:parameter/ses/auth0/*",
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}:parameter/terraform/auth0-access/*",
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}:parameter/forms-admin-${var.env_name}/auth0/*",
    ]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "dns" {
  statement {
    sid = "GetCloudfrontDistribution"
    actions = [
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListTagsForResource",
    ]
    # TODO: do we need to specify a distribution?
    resources = [
      "arn:aws:cloudfront::${lookup(local.account_ids, var.env_name)}:distribution/*",
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageRoute53RecordSets"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${var.hosted_zone_id}"
    ]
  }
}

data "aws_iam_policy_document" "monitoring" {
  statement {
    sid = "ManageCloudwatchDashboards"
    actions = [
      "cloudwatch:GetDashboard",
      "cloudwatch:DeleteDashboards",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:PutDashboard",
      "cloudwatch:TagResource",
      "cloudwatch:UntagResource",
    ]
    resources = [
      "arn:aws:cloudwatch:*:${lookup(local.account_ids, var.env_name)}:dashboard/*"
    ]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "rds" {
  statement {
    sid = "ManageRDS"
    actions = [
      "rds:*DBCluster*",
      "rds:*SecurityGroup*",
      "rds:*SubnetGroup*",
      "rds:*Tag*",
    ]
    resources = [
      "arn:aws:rds:eu-west-2:${lookup(local.account_ids, var.env_name)}:*"
    ]
    effect = "Allow"
  }

  statement {
    sid    = "GetSSMParams"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}:parameter/database/master-password"
    ]
  }
}

data "aws_iam_policy_document" "ses" {
  #checkov:skip=CKV_AWS_111:We use SES v1 which doesn't let us be more specific than *
  #checkov:skip=CKV_AWS_356:We use SES v1 which doesn't let us be more specific than *
  statement {
    sid    = "GetUser"
    effect = "Allow"
    actions = [
      "iam:GetUser",
      "iam:AttachUserPolicy",
      "iam:DeleteUserPolicy",
      "iam:DetachUserPolicy",
      "iam:GetUserPolicy",
      "iam:ListAccessKeys",
      "iam:ListAttachedUserPolicies",
      "iam:ListUserTags",
      "iam:UntagUser",
    ]
    resources = [
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:user/auth0"
    ]
  }

  statement {
    sid    = "ManageSESPolicies"
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyTags",
      "iam:TagPolicy",
      "iam:UntagPolicy",
    ]
    resources = [
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:policy/ses_sender"
    ]
  }

  statement {
    sid    = "ManageSESVerification"
    effect = "Allow"
    actions = [
      "ses:GetIdentityVerificationAttributes",
      "ses:*Dkim*",
      "ses:*EmailAddress*",
      "ses:*Domain*",
      "ses:VerifyEmailIdentity",
    ]
    resources = [
      "*"
    ]
  }

  # We use SES v1 (I think?)... in v2 you can specify resources
  statement {
    sid    = "ManageSESConfigurationSet"
    effect = "Allow"
    actions = [
      "ses:*ConfigurationSet*",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "ManageKMSKeySES"
    effect = "Allow"
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
      "arn:aws:kms:eu-west-2:${lookup(local.account_ids, var.env_name)}:key/*",
    ]
  }

  statement {
    sid    = "ManageSQS"
    effect = "Allow"
    actions = [
      "sqs:*queue*"
    ]
    resources = [
      "arn:aws:sqs:eu-west-2:${lookup(local.account_ids, var.env_name)}:*"
    ]
  }

  statement {
    sid = "ManageSNS"
    actions = [
      "sns:*Topic*",
      "sns:GetSubscriptionAttributes",
      "sns:*Tag*",
      "sns:*Subscrib*",
      "sns:Unsubscribe",
      "sns:UntagResource",
    ]
    resources = [
      "arn:aws:sns:eu-west-2:${lookup(local.account_ids, var.env_name)}:ses_bounces_and_complaints_topic",
    ]
    effect = "Allow"
  }


}

data "aws_iam_policy_document" "forms-infra" {
  source_policy_documents = [
    data.aws_iam_policy_document.alerts.json,
    data.aws_iam_policy_document.auth0.json,
    data.aws_iam_policy_document.dns.json,
    data.aws_iam_policy_document.monitoring.json,
    data.aws_iam_policy_document.rds.json,
  ]
}

resource "aws_iam_policy" "forms-infra" {
  policy = data.aws_iam_policy_document.forms-infra.json
}

resource "aws_iam_role_policy_attachment" "forms-infra" {
  policy_arn = aws_iam_policy.forms-infra.arn
  role       = aws_iam_role.deployer.id
}

data "aws_iam_policy_document" "forms-infra-1" {
  source_policy_documents = [
    data.aws_iam_policy_document.redis.json,
    data.aws_iam_policy_document.ses.json,
  ]
}

resource "aws_iam_policy" "forms-infra-1" {
  policy = data.aws_iam_policy_document.forms-infra-1.json
}

resource "aws_iam_role_policy_attachment" "forms-infra-1" {
  policy_arn = aws_iam_policy.forms-infra-1.arn
  role       = aws_iam_role.deployer.id
}
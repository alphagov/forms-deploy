data "aws_iam_policy_document" "forms-infra" {
  source_policy_documents = [
    data.aws_iam_policy_document.alerts.json,
    data.aws_iam_policy_document.auth0.json,
    data.aws_iam_policy_document.dns.json,
    data.aws_iam_policy_document.monitoring.json,
  ]
}

data "aws_iam_policy_document" "forms-infra-1" {
  source_policy_documents = [
    data.aws_iam_policy_document.rds.json,
    data.aws_iam_policy_document.redis.json,
    data.aws_iam_policy_document.code-build-modules.json,
  ]
}

data "aws_iam_policy_document" "forms-infra-2" {
  source_policy_documents = [
    data.aws_iam_policy_document.smoketests.json,
    data.aws_iam_policy_document.ses.json,
    data.aws_iam_policy_document.pipelines.json,
  ]
}

resource "aws_iam_policy" "forms-infra" {
  policy = data.aws_iam_policy_document.forms-infra.json
}

resource "aws_iam_role_policy_attachment" "forms-infra" {
  policy_arn = aws_iam_policy.forms-infra.arn
  role       = aws_iam_role.deployer.id
}

resource "aws_iam_policy" "forms-infra-1" {
  policy = data.aws_iam_policy_document.forms-infra-1.json
}

resource "aws_iam_role_policy_attachment" "forms-infra-1" {
  policy_arn = aws_iam_policy.forms-infra-1.arn
  role       = aws_iam_role.deployer.id
}

resource "aws_iam_policy" "forms-infra-2" {
  policy = data.aws_iam_policy_document.forms-infra-2.json
}

resource "aws_iam_role_policy_attachment" "forms-infra-2" {
  policy_arn = aws_iam_policy.forms-infra-2.arn
  role       = aws_iam_role.deployer.id
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

# This relates to the `dns` root and is different from what is covered in by the permissions in the `environment` module
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

data "aws_iam_policy_document" "code-build-modules" {
  # These are needed for: 
  # code-build-build
  # code-build-run-docker-build
  # code-build-run-smoke-tests
  statement {
    sid    = "ManageLogs"
    effect = "Allow"
    actions = [
      "logs:*LogEvents",
      "logs:*LogStream",
      "logs:*SubscriptionFilters",
      "logs:*LogGroup",
    ]
    resources = [
      "arn:aws:logs:eu-west-2:${lookup(local.account_ids, var.env_name)}:log-group:/aws/codebuild/*",
      "arn:aws:logs:eu-west-2:${lookup(local.account_ids, var.env_name)}:log-group:codebuild/*"
    ]
  }
  statement {
    sid    = "ManageCodebuild"
    effect = "Allow"
    actions = [
      "codebuild:*Project*",
      "codebuild:*Build*",
    ]
    resources = [
      "arn:aws:codebuild:eu-west-2:${lookup(local.account_ids, var.env_name)}:project/*"
    ]
  }
  statement {
    sid    = "ManageCodebuildRoles"
    effect = "Allow"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:DeleteRole",
      "iam:PassRole",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies"
    ]
    resources = [
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/codebuild-*",
    ]
  }
  statement {
    sid    = "ManageCodebuildPolicies"
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy"
    ]
    resources = [
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:policy/codebuild-*"
    ]
  }
}

data "aws_iam_policy_document" "smoketests" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = [
      "arn:aws:ecr:eu-west-2:${local.deploy_account_id}:repository/end-to-end-tests",
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageSSMParameters"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}:parameter/${var.env_name}/smoketests/*",
    ]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "pipelines" {
  statement {
    actions = [
      "codestar-connections:UseConnection",
      "codestar-connections:GetConnection",
      "codestar-connections:ListConnections"
    ]
    resources = [var.codestar_connection_arn]
    effect    = "Allow"
  }

  statement {
    actions   = ["codecommit:Get*", "codecommit:Describe*", "codecommit:GitPull"]
    resources = [var.codestar_connection_arn]
    effect    = "Allow"
  }

  statement {
    sid       = "ManageArtifactBuckets"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::pipeline-*", "arn:aws:s3:::pipeline-*/*"]
  }
}
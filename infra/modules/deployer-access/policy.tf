##
# When adding and editing policies for the deployer role,
# you should focus on create, update, delete, or otherwise mutating
# actions. The role has full read-only access.
##

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
    data.aws_iam_policy_document.ses.json,
    data.aws_iam_policy_document.pipelines.json,
    data.aws_iam_policy_document.ecr.json,
    data.aws_iam_policy_document.eventbridge.json,
    data.aws_iam_policy_document.cloudwatch_logging.json,
    data.aws_iam_policy_document.shield.json,
    data.aws_iam_policy_document.route53.json,
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

resource "aws_iam_role_policy_attachment" "full_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  role       = aws_iam_role.deployer.id
}

data "aws_iam_policy_document" "alerts" {
  statement {
    sid = "ManageKMSKeyAlerts"
    actions = [
      "kms:EnableKeyRotation",
      "kms:PutKeyPolicy",
      "kms:TagResource",
      "kms:UpdateKeyDescription",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion"
    ]
    resources = [
      # TODO: be more specific?
      "arn:aws:kms:eu-west-2:${lookup(local.account_ids, var.env_name)}:key/*",
    ]
    effect = "Allow"
  }

  statement {
    sid       = "CreateKMSKeys"
    actions   = ["kms:CreateKey"]
    resources = ["*"] #CreateKey uses the * resource
    effect    = "Allow"
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
      "ssm:PutParameter",
      "ssm:RemoveTagsFromResource",
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}:parameter/alerting/email-zendesk",
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}:parameter/alerting/${var.env_name}/pagerduty-integration-url",
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}:parameter/alerting/${var.env_name}/pager-duty-integration-url",
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}:parameter/${var.env_name}/automated-tests/*",
    ]
    effect = "Allow"
  }

  statement {
    sid = "ManageSNS"
    actions = [
      "sns:*Topic*",
      "sns:*Tag*",
      "sns:*Subscrib*",
      "sns:Unsubscribe",
      "sns:UntagResource",
    ]
    resources = [
      "arn:aws:sns:eu-west-2:${lookup(local.account_ids, var.env_name)}:pager_duty_integration_${var.env_name}",
      "arn:aws:sns:eu-west-2:${lookup(local.account_ids, var.env_name)}:pagerduty_integration_${var.env_name}",
      "arn:aws:sns:eu-west-2:${lookup(local.account_ids, var.env_name)}:alert_zendesk_${var.env_name}",
      "arn:aws:sns:us-east-1:${lookup(local.account_ids, var.env_name)}:cloudwatch-alarms",
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
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}:parameter/${var.env_name}/splunk/*",
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}:parameter/terraform/auth0-access/*",
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}:parameter/forms-admin-${var.env_name}/*",
    ]
    effect = "Allow"
  }
}

# This relates to the `dns` root and is different from what is covered in by the permissions in the `environment` module
data "aws_iam_policy_document" "dns" {
  statement {
    sid = "ManageRoute53RecordSets"
    actions = [
      "route53:ChangeResourceRecordSets",
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
      "cloudwatch:DeleteDashboards",
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
  #checkov:skip=CKV_AWS_109:We have a plan to add a permissions boundary to the deployer
  statement {
    sid    = "GetUser"
    effect = "Allow"
    actions = [
      "iam:AttachUserPolicy",
      "iam:DeleteUserPolicy",
      "iam:DetachUserPolicy",
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
      "iam:DeletePolicyVersion",
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
      "ses:*Dkim*",
      "ses:*EmailAddress*",
      "ses:*Domain*",
      "ses:VerifyEmailIdentity",
      "ses:*Identity*"
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
      "kms:EnableKeyRotation",
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
      "sns:*Tag*",
      "sns:*Subscrib*",
      "sns:Unsubscribe",
      "sns:UntagResource",
    ]
    resources = [
      "arn:aws:sns:eu-west-2:${lookup(local.account_ids, var.env_name)}:ses_bounces_and_complaints",
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
    sid    = "ManageRoles"
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
      "iam:TagRole"
    ]
    resources = [
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/codebuild-*",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/${var.env_name}-event-bridge-*",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/event-bridge-actor",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/deployer-${var.env_name}"
    ]
  }
  statement {
    sid    = "ManagePolicies"
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:TagPolicy"
    ]
    resources = [
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:policy/codebuild-*",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:policy/${var.env_name}-event-bridge-*",
    ]
  }
}

data "aws_iam_policy_document" "pipelines" {
  statement {
    actions = [
      "codestar-connections:UseConnection",
      "codestar-connections:PassConnection"
    ]
    resources = [var.codestar_connection_arn]
    effect    = "Allow"
  }

  statement {
    actions   = ["codecommit:GitPull"]
    resources = [var.codestar_connection_arn]
    effect    = "Allow"
  }

  statement {
    sid       = "ManageArtifactBuckets"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::pipeline-*", "arn:aws:s3:::pipeline-*/*"]
  }

  statement {
    sid     = "ManageLambdaBuckets"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::govuk-forms-*-pipeline-invoker",
      "arn:aws:s3:::govuk-forms-*-pipeline-invoker/*"
    ]
  }

  statement {
    sid    = "ManageLambdaFunctions"
    effect = "Allow"
    actions = [
      "lambda:*Function",
      "lambda:*Permission",
      "lambda:PutFunctionConcurrency",
      "lambda:TagResource",
      "lambda:UntagResource",
      "lambda:UpdateFunctionCode",
    ]

    resources = [
      "arn:aws:lambda:*:${lookup(local.account_ids, var.env_name)}:function:*-pipeline-invoker"
    ]
  }

  statement {
    sid    = "ManagePipelines"
    effect = "Allow"
    actions = [
      "codepipeline:CreatePipeline",
      "codepipeline:DeletePipeline",
      "codepipeline:UpdatePipeline",
      "codepipeline:TagResource",
      "codepipeline:UntagResource",
    ]

    resources = [
      "arn:aws:codepipeline:eu-west-2:${lookup(local.account_ids, var.env_name)}:*"
    ]
  }
}

data "aws_iam_policy_document" "ecr" {
  statement {
    actions = [
      "ecr:*"
    ]
    resources = [
      "arn:aws:ecr:eu-west-2:${local.deploy_account_id}:*",
    ]
    effect = "Allow"
  }

  statement {
    # CodePipeline appears to peform GetAuthorizationToken
    # with resource "*", and a statement with an ARN
    # like "arn:aws:ecr::ACCT_ID:*" is insufficient to grant
    # it permission
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
    effect    = "Allow"
  }
}

data "aws_iam_policy_document" "eventbridge" {
  #checkov:skip=CKV_AWS_356: resource "*" is restricted to events actions
  #checkov:skip=CKV_AWS_111: there are many event resources the deployer
  #                          role will write to, and adding conditions for
  #                          each will add a lot to an already constrained
  #                          character count
  statement {
    sid    = "AllowEventActions"
    effect = "Allow"
    actions = [
      "events:*"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowPassRoleForEventBridge"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::*:role/*"]

    condition {
      variable = "iam:PassedToService"
      test     = "StringLike"
      values   = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_logging" {
  statement {
    actions = [
      "logs:PutRetentionPolicy",
      "logs:DeleteLogGroup",
      "logs:DeleteRetentionPolicy",
      "logs:DeleteSubscriptionFilter",
    ]
    resources = [
      "arn:aws:logs:eu-west-2:${lookup(local.account_ids, var.env_name)}:log-group:*",
      "arn:aws:logs:us-east-1:${lookup(local.account_ids, var.env_name)}:log-group:*",
    ]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "shield" {
  statement {
    sid = "ShieldPermissionsProtectionResources"
    actions = [
      "shield:*HealthCheck",
      "shield:*Protection",
      "shield:TagResource",
      "shield:UntagResource",
    ]
    resources = [
      "arn:aws:shield::${lookup(local.account_ids, var.env_name)}:protection/*",
    ]
    effect = "Allow"
  }

  statement {
    sid = "ShieldPermissionsProtectionGroupResources"
    actions = [
      "shield:*ProtectionGroup",
      "shield:ListProtectionGroups",
      "shield:ListResourcesInProtectionGroup",
      "shield:TagResource",
      "shield:UntagResource",

    ]
    resources = [
      "arn:aws:shield::${lookup(local.account_ids, var.env_name)}:protection-group/*",
    ]
    effect = "Allow"
  }

  statement {
    sid = "ShieldPermissionsAllResources"
    actions = [
      "shield:*DRTLogBucket",
      "shield:*DRTRole",
      "shield:AssociateProactiveEngagementDetails",
      "shield:CreateProtection",
      "shield:EnableApplicationLayerAutomaticResponse",
      "shield:EnableProactiveEngagement",
      "shield:DisableApplicationLayerAutomaticResponse",
      "shield:DisableProactiveEngagement",
      "shield:UpdateEmergencyContactSettings",
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }

  statement {
    sid = "ShieldPermissionsIAM"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateServiceLinkedRole",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UpdateRole",
    ]
    resources = [
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/shield-response-team",
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}:role/aws-service-role/shield.amazonaws.com/AWSServiceRoleForAWSShield"
    ]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "route53" {
  statement {
    sid = "CreateRoute53HealthChecks"
    actions = [
      "route53:CreateHealthCheck"
    ]
    resources = ["*"] # CreateHealthCheck uses *
    effect    = "Allow"
  }

  statement {
    sid = "ConfigureRoute53HealthChecks"
    actions = [
      "route53:ChangeTagsForResource",
      "route53:DeleteHealthCheck",
    ]
    resources = [
      "arn:aws:cloudwatch:eu-west-2:${lookup(local.account_ids, var.env_name)}:${var.env_name}_cloudfront_total_error_rate",
      "arn:aws:cloudwatch:us-east-1:${lookup(local.account_ids, var.env_name)}:ddos_detected_in_${var.env_name}",
      "arn:aws:route53:::healthcheck/*"
    ]
    effect = "Allow"
  }
}

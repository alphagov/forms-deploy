# This file contains the policies for:
# - code-build-docker-build
# - code-build-run-smoke-tests
# - deployer-access 
# - ecs-service
# - rds

# code-build-docker-build
data "aws_iam_policy_document" "code-build-docker-build" {
  statement {
    sid    = "ManageLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DeleteLogGroup",
      "logs:DescribeSubscriptionFilters",
      "logs:PutSubscriptionFilter",
      "logs:DeleteSubscriptionFilter",
    ]
    resources = [
      "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.project_name}:*",
      "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:codebuild/${local.project_name}:*"
    ]
  }
  statement {
    sid    = "ManageCodebuild"
    effect = "Allow"
    actions = [
      "codebuild:CreateProject",
      "codebuild:DeleteProject",
      "codebuild:BatchGetProjects",
      "codebuild:ListProjects",
      "codebuild:UpdateProject"
    ]
    resources = [ # NOTE: we have a lot of codebuild projects, will we have to add them all here? can we get an for each loop here
      "arn:aws:codebuild:eu-west-2:${data.aws_caller_identity.current.account_id}:project/${local.project_name}"
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
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/codebuild-${var.project_name}",
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
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/codebuild-${var.project_name}"
    ]
  }
}

# code-build-run-smoke-tests NOTE: I think this is identical to code-build-docker-build (just the resource names will be different)
data "aws_iam_policy_document" "code-build-run-smoke-tests" {
  statement {
    sid    = "ManageLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams", # NOTE: do log streams need difference resources?
      "logs:DeleteLogGroup",
    ]
    resources = [
      "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.project_name}:*",
      "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:codebuild/${local.project_name}:*"
    ]
  }
  statement {
    sid    = "ManageCodebuild"
    effect = "Allow"
    actions = [
      "codebuild:CreateProject",
      "codebuild:DeleteProject",
      "codebuild:BatchGetProjects",
      "codebuild:ListProjects",
      "codebuild:UpdateProject"
    ]
    resources = [ # NOTE: we have a lot of codebuild projects, will we have to add them all here? can we get an for each loop here
      "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:project/${local.project_name}"
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
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/codebuild-${var.project_name}",
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
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/codebuild-${var.project_name}"
    ]
  }
}

# deployer-access <should this be part of the account deployment really?>
data "aws_iam_policy_document" "deployer-access" {
  statement {
    sid    = "ManageDeployRoles"
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
      "arn:aws:iam::${lookup(local.account_ids, var.env_name)}}:role/deployer-${var.env_name}",
    ]
  }
  statement {
    sid    = "ManageDeployPolicies"
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy"
    ]
    resources = [
      "TBD", # NOTE: none of the policies that are created in infra/modules/deployer-access/policy are named - 
      #they have autogenerated names so we can't add them to the resources file
    ]
  }
}

# ecs-service
data "aws_iam_policy_document" "ecs-service" {
  statement {
    sid    = "ManageLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DeleteLogGroup",
      "logs:DescribeSubscriptionFilters",
      "logs:PutSubscriptionFilter",
      "logs:DeleteSubscriptionFilter",
    ]
    resources = [
      "arn:aws:logs:eu-west-2:${lookup(local.account_ids, var.env_name)}:log-group:forms-admin-${var.env_name}:*",
      "arn:aws:logs:eu-west-2:${lookup(local.account_ids, var.env_name)}:log-group:forms-api-${var.env_name}:*",
      "arn:aws:logs:eu-west-2:${lookup(local.account_ids, var.env_name)}:log-group:forms-runner-${var.env_name}:*",
      "arn:aws:logs:eu-west-2:${lookup(local.account_ids, var.env_name)}:log-group:forms-product-page-${var.env_name}:*"
    ]
  }
  statement {
    sid    = "ManageALBTargetGroups"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:eu-west-2:${lookup(local.account_ids, var.env_name)}:targetgroup/${var.application}-${var.env_name}/*"
    ]
  }
  statement {
    sid    = "ManageALB"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateListener", # I know this looks wrong, but createlistener needs to be on the loadbalancer, not the listener
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:eu-west-2:${lookup(local.account_ids, var.env_name)}:loadbalancer/*/forms-${var.env_name}/*"
    ]
  }

  statement {
    sid    = "ManageALBListeners"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:CreateRule", # create rule needs to be on the listener, not the rule
    ]
    resources = [
      "arn:aws:elasticloadbalancing:eu-west-2:${lookup(local.account_ids, var.env_name)}:listener/*/forms-${var.env_name}/*"
    ]
  }

  statement {
    sid    = "ManageALBListenerRules"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:ModifyRule",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:eu-west-2:${lookup(local.account_ids, var.env_name)}:listener-rule/*/forms-${var.env_name}/*"
    ]
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
    resources = [ # NOTE: this has to be *
      "*"
    ]
    effect = "Allow"
  }

  statement {
    sid    = "ManageALBListenerRules"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:ModifyRule",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:eu-west-2:${lookup(local.account_ids, var.env_name)}:listener-rule/*/forms-${var.env_name}/*"
    ]
  }

  statement {
    sid    = "ManageApplicationAutoScaling"
    effect = "Allow"
    actions = [
      "application-autoscaling:RegisterScalableTarget",
      "application-autoscaling:DeegisterScalableTarget",
      "application-autoscaling:PutScalingPolicy",
      "application-autoscaling:DeleteScalingPolicy",
      "application-autoscaling:PutScheduledAction",
    ]
    resources = [
      "arn:aws:application-autoscaling:eu-west-2:${lookup(local.account_ids, var.env_name)}:scalable-target/*"
    ]
  }

  statement {
    sid    = "ListApplicationAutoScalingResources"
    effect = "Allow"
    actions = [
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingPolicies",
      "application-autoscaling:DescribeScheduledActions",
      "application-autoscaling:DescribeScalingActivities",
    ]
    resources = ["*"] # NOTE: this has to be *
  }

  statement {
    sid = "ManageServiceLinkedRoleForAutoscaling"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = [ # NOTE: we're currently using a service role for this, might be worth making out own role in the future?
      "arn:aws:iam::*:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
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
    sid    = "ManageCloudWatchAlarms"
    effect = "Allow"
    actions = [
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:EnableAlarmActions",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:ListTagsForResource"
    ]
    resources = [
      "arn:aws:cloudwatch:eu-west-2:${local.account_ids[var.env_name]}:alarm:${var.env_name}-${var.application}-target-response-time-low",
      "arn:aws:cloudwatch:eu-west-2:${local.account_ids[var.env_name]}:alarm:${var.env_name}-${var.application}-target-response-time-high",
    ]
  }

  statement {
    sid    = "ManageEcsClusters"
    effect = "Allow"
    actions = [
      "ecs:DescribeClusters",
      "ecs:ListContainerInstances",
      "ecs:UpdateCluster",
      "ecs:UpdateClusterSettings"
    ]
    resources = [
      "arn:aws}:ecs:eu-west-2:${local.account_ids[var.env_name]}:cluster/forms-${var.env_name}"
    ]
  }

  statement {
    sid    = "DescribeEcsClusters"
    effect = "Allow"
    actions = [
      "ecs:DescribeClusters",
      "ecs:ListClusters"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ManageECSTaskDefinitions"
    effect = "Allow"
    actions = [
      "ecs:DeleteTaskDefinitions",
      "ecs:ListTagsForResource"
    ]
    resources = [
      "arn:aws:ecs:eu-west-2:${local.account_ids[var.env_name]}:task-definition/${var.env_name}_${var.application}:*"
    ]
  }

  statement {
    sid    = "ManageECSServices"
    effect = "Allow"
    actions = [
      "ecs:CreateService",
      "ecs:DeleteService",
      "ecs:DescribeServices",
      "ecs:UpdateService",
    ]
    resources = [
      "arn:aws:ecs:eu-west-2:${local.account_ids[var.env_name]}:service/${var.env_name}_${var.application}:${var.application}"
    ]
  }

  statement {
    sid    = "DescribeEcsServices"
    effect = "Allow"
    actions = [
      "ecs:ListServices",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ManageTaskAndTaskExecutionRoles"
    effect = "Allow"
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
  }

  statement {
    sid    = "ManageEcsTaskExecutionPolicies"
    effect = "Allow"
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
    sid    = "ManageSecurityGroups"
    effect = "Allow"
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
      "arn:aws:ec2:eu-west-2:${lookup(local.account_ids, var.env_name)}:security-group/*"
    ]
  }

  statement {
    sid    = "ManageSecurityGroupRules"
    effect = "Allow"
    actions = [
      "ec2:ModifySecurityGroupRules",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
    ]
    resources = [
      "arn:aws:ec2:eu-west-2:${lookup(local.account_ids, var.env_name)}:security-group-rule/*"
    ]
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

# rds
data "aws_iam_policy_document" "rds" {
  statement {
    sid    = "ManageRDSSubnets"
    effect = "Allow"
    actions = [
      "rds:CreateDBSubnetGroup",
      "rds:DeleteDBSubnetGroup",
      "rds:DescribeDBSubnetGroups",
      "rds:ListTagsForResource",
      "rds:ModifyDBSubnetGroup",
      "rds:RemoveTagsFromResource"
    ]
    resources = [
      "arn:aws:rds:eu-west-2:${lookup(local.account_ids, var.env_name)}}:subgrp:rds-${var.env_name}"
    ]
  }

  statement {
    sid    = "GetSSMParams"
    effect = "Allow"
    actions = [
      "ssm:GetSecretValue",
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}}:parameter/database/master-password"
    ]
  }

  statement {
    sid    = "ManageRDSParameterGroups"
    effect = "Allow"
    actions = [
      "rds:CreateDBClusterParameterGroup",
      "rds:CreateDBCluster",
      "rds:DeleteDBClusterParameterGroup",
      "rds:DescribeDBClusterParameterGroups",
      "rds:DescribeDBClusterParameters",
      "rds:ModifyDBCluster",
      "rds:ModifyDBClusterParameterGroup",
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}}:cluster-pg/forms-${var.env_name}*"
    ]
  }

  statement {
    sid    = "ManageRDSCluster"
    effect = "Allow"
    actions = [
      "rds:CreateDBCluster",
      "rds:CreateDBClusterEndpoint",
      "rds:CreateDBClusterSnapshot",
      "rds:DeleteDBCluster",
      "rds:ModifyDBCluster",
      "rds:DescribeDBClusters",
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:${lookup(local.account_ids, var.env_name)}}:cluster/aurora-cluster-${var.env_name}"
    ]
  }

  statement {
    sid    = "ManageSecurityGroups"
    effect = "Allow"
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
      "arn:aws:ec2:eu-west-2:${lookup(local.account_ids, var.env_name)}:security-group/*"
    ]
  }


}
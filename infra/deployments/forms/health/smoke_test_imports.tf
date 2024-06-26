# The imports in this file are in the lexical order the resources were defined
# within in each file in ./monitoring/smoke-test, ordered alphabetically
locals {
  test_name = "runner-smoke-test"
}

import {
  for_each = var.scheduled_smoke_tests_settings.enable_scheduled_smoke_tests ? [1] : []
  id       = "${local.test_name}-failing"
  to       = module.monitoring.module.runner_scheduled_smoke_tests[0].aws_cloudwatch_metric_alarm.failing
}

import {
  for_each = var.scheduled_smoke_tests_settings.enable_scheduled_smoke_tests ? [1] : []
  id       = "${local.test_name}-not-running"
  to       = module.monitoring.module.runner_scheduled_smoke_tests[0].aws_cloudwatch_metric_alarm.not_running
}

import {
  for_each = var.scheduled_smoke_tests_settings.enable_scheduled_smoke_tests ? [1] : []
  id       = "${var.environment_name}-${local.test_name}"
  to       = module.monitoring.module.runner_scheduled_smoke_tests[0].aws_codebuild_project.run_test
}

import {
  for_each = var.scheduled_smoke_tests_settings.enable_scheduled_smoke_tests ? [1] : []
  id       = "default/schedule-${local.test_name}-${var.environment_name}"
  to       = module.monitoring.module.runner_scheduled_smoke_tests[0].aws_cloudwatch_event_rule.scheduler
}

import {
  for_each = var.scheduled_smoke_tests_settings.enable_scheduled_smoke_tests ? [1] : []
  id       = "default/schedule-${local.test_name}-${var.environment_name}/StartTest"
  to       = module.monitoring.module.runner_scheduled_smoke_tests[0].aws_cloudwatch_event_target.start_test
}

import {
  for_each = var.scheduled_smoke_tests_settings.enable_scheduled_smoke_tests ? [1] : []
  id       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.environment_name}-event-bridge-${local.test_name}"
  to       = module.monitoring.module.runner_scheduled_smoke_tests[0].aws_iam_policy.event_bridge
}

import {
  for_each = var.scheduled_smoke_tests_settings.enable_scheduled_smoke_tests ? [1] : []
  id       = "${var.environment_name}-event-bridge-scheduler-${local.test_name}"
  to       = module.monitoring.module.runner_scheduled_smoke_tests[0].aws_iam_role.event_bridge
}

import {
  for_each = var.scheduled_smoke_tests_settings.enable_scheduled_smoke_tests ? [1] : []
  id       = "${var.environment_name}-event-bridge-scheduler-${local.test_name}/arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.environment_name}-event-bridge-${local.test_name}"
  to       = module.monitoring.module.runner_scheduled_smoke_tests[0].aws_iam_role_policy_attachment.event_bridge
}

import {
  for_each = var.scheduled_smoke_tests_settings.enable_scheduled_smoke_tests ? [1] : []
  id       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/codebuild-${local.test_name}-${var.environment_name}"
  to       = module.monitoring.module.runner_scheduled_smoke_tests[0].aws_iam_policy.codebuild
}

import {
  for_each = var.scheduled_smoke_tests_settings.enable_scheduled_smoke_tests ? [1] : []
  id       = "codebuild-${local.test_name}-${var.environment_name}"
  to       = module.monitoring.module.runner_scheduled_smoke_tests[0].aws_iam_role.codebuild
}

import {
  for_each = var.scheduled_smoke_tests_settings.enable_scheduled_smoke_tests ? [1] : []
  id       = "codebuild-${local.test_name}-${var.environment_name}/arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/codebuild-${local.test_name}-${var.environment_name}"
  to       = module.monitoring.module.runner_scheduled_smoke_tests[0].aws_iam_role_policy_attachment.codebuild
}

import {
  for_each = var.scheduled_smoke_tests_settings.enable_scheduled_smoke_tests ? [1] : []
  id       = "codebuild/scheduled-${local.test_name}-${var.environment_name}"
  to       = module.monitoring.module.runner_scheduled_smoke_tests[0].aws_cloudwatch_log_group.log_group
}
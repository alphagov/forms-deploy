locals {
  alerts_topic_name              = "CodeStarNotifications-govuk-forms-alert-b7410628fe547543676d5dc062cf342caba48bcd"
  deployments_topic_name         = "CodeStarNotifications-govuk-forms-deployments-c383f287ab987f0b12d32e4533a145b1c918167d"
  infra_notifications_topic_name = "govuk-forms-infra-notifications"

  region = "eu-west-2"
}

output "alerts_topic_name" {
  description = "Name of the SNS topic for ChatBot alerts channel"
  value       = local.alerts_topic_name
}

output "alerts_topic_arn" {
  description = "ARN of the SNS topic for ChatBot alerts channel"
  value       = "arn:aws:sns:${local.region}:${module.all_accounts.deploy_account_id}:${local.alerts_topic_name}"
}

output "deployments_topic_name" {
  description = "Name of the SNS topic for ChatBot deployments channel"
  value       = local.deployments_topic_name
}

output "deployments_topic_arn" {
  description = "ARN of the SNS topic for ChatBot deployments channel"
  value       = "arn:aws:sns:${local.region}:${module.all_accounts.deploy_account_id}:${local.deployments_topic_name}"
}

output "infra_notifications_topic_name" {
  description = "Name of the SNS topic for ChatBot infra notifications channel"
  value       = local.infra_notifications_topic_name
}

output "infra_notifications_topic_arn" {
  description = "ARN of the SNS topic for ChatBot infra notifications channel"
  value       = "arn:aws:sns:${local.region}:${module.all_accounts.deploy_account_id}:${local.infra_notifications_topic_name}"
}

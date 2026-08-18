resource "aws_cloudwatch_event_target" "guardduty_runtime_protection_to_sns" {
  #checkov:skip=CKV2_FORMS_AWS_6:Dead Letter Queue will be added when needed
  target_id = "send-to-sns"
  rule      = aws_cloudwatch_event_rule.guardduty_runtime_protection_failure.name
  arn       = local.alert_severity.eu_west_2.info

  input_transformer {
    input_paths = {
      detail_type = "$.detail-type"
      event_time  = "$.time"

      previous_status = "$.detail.previousStatus"
      current_status  = "$.detail.currentStatus"
      account_id      = "$.detail.resourceAccountId"

      resource_type = "$.detail.resourceDetails.resourceType"
      cluster_name  = "$.detail.resourceDetails.ecsClusterDetails.clusterName"

      issues = "$.detail.resourceDetails.ecsClusterDetails.fargateDetails.issues"
    }
    input_template = <<EOF
{
  "title": "GuardDuty Runtime Protection Unhealthy. GuardDuty has detected a potential threat or is not working as expected",
  "Account": <account_id>,
  "Type": <detail_type>,
  "Time": <event_time>,
  "Status": {
    "Previous": <previous_status>,
    "Current": <current_status>},
  "Resource": {
    "Type": <resource_type>,
    "Cluster": <cluster_name>},
  "Issues":  <issues>,
  "Next steps": {
    "1": "Go to the GuardDuty console in AWS --> Runtime coverage --> ECS clusters runtime coverage: has the coverage status changed back to Healthy? If so, it is likely the GuardDuty agent was not available and then recovered automatically. You can dismiss this notification. If the status is Unhealthy, continue to the next step.",
    "2" : "Check this notification for the Issues.",
    "3": "Decide if the Issues listed are related to troubleshooting GuardDuty Runtime Coverage by comparing the Issues to the ones listed by AWS: https://docs.aws.amazon.com/guardduty/latest/ug/gdu-assess-coverage-ecs.html . Follow the recommended troublesooting steps",
    "4": "If not a troubleshooting issue, explore the GuardDuty Findings for Runtime Monitoring and follow the remediation recommendations: https://docs.aws.amazon.com/guardduty/latest/ug/findings-runtime-monitoring.html"}
}
EOF
  }
}

resource "aws_cloudwatch_event_rule" "guardduty_runtime_protection_failure" {
  name        = "guardduty-runtime-protection-failure"
  description = "Notifies when the coverage status in GuardDuty Runtime Protection changes from Healthy to Unhealthy in the ${var.environment} environment"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Runtime Protection Unhealthy"]
  })
}

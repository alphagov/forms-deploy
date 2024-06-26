# The imports in this file are in the lexical order the resources were defined
# within in each file in ./monitoring, ordered alphabetically

import {
  id = "${var.environment_name}-event-bridge-delivered-dead-letters"
  to = module.monitoring.aws_cloudwatch_metric_alarm.event_bridge_dlq_delivery_alarm
}

import {
  id = "Overview"
  to = module.monitoring.aws_cloudwatch_dashboard.overview
}
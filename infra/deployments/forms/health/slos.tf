locals {
  # Common SLO configuration
  common_burn_rate_configurations = [
    { look_back_window_minutes = 5 },
    { look_back_window_minutes = 30 },
    { look_back_window_minutes = 60 },
    { look_back_window_minutes = 360 },
    { look_back_window_minutes = 4320 }
  ]

  common_goal_config = {
    interval = {
      rolling_interval = {
        duration      = 28
        duration_unit = "DAY"
      }
    }
    warning_threshold = 30.0
  }

  # Availability SLO definitions
  availability_slos = {
    admin_http_availability = {
      name              = "admin-http-availability"
      description       = "99% of requests as measured from the load balancer metrics are successful. Any HTTP status other than 500-599 is considered successful."
      attainment_goal   = 99
      service           = "forms-admin"
      target_group_name = data.aws_lb_target_group.forms_admin_tg.arn_suffix
    }
    runner_http_availability = {
      name              = "runner-http-availability"
      description       = "99% of requests as measured from the load balancer metrics are successful. Any HTTP status other than 500-599 is considered successful."
      attainment_goal   = 99
      service           = "forms-runner"
      target_group_name = data.aws_lb_target_group.forms_runner_tg.arn_suffix
    }
  }

  # Latency SLO definitions
  latency_slos = {
    admin_http_latency_400ms = {
      name              = "admin-http-latency-400ms"
      description       = "90% of requests as measured from the load balancer metrics are under 400ms."
      attainment_goal   = 90
      service           = "forms-admin"
      target_group_name = data.aws_lb_target_group.forms_admin_tg.arn_suffix
      threshold         = "0.4"
    }
    admin_http_latency_1000ms = {
      name              = "admin-http-latency-1000ms"
      description       = "99% of requests as measured from the load balancer metrics are under 1000ms."
      attainment_goal   = 99
      service           = "forms-admin"
      target_group_name = data.aws_lb_target_group.forms_admin_tg.arn_suffix
      threshold         = "1"
    }
    runner_http_latency_200ms = {
      name              = "runner-http-latency-200ms"
      description       = "90% of requests as measured from the load balancer metrics are under 200ms."
      attainment_goal   = 90
      service           = "forms-runner"
      target_group_name = data.aws_lb_target_group.forms_runner_tg.arn_suffix
      threshold         = "0.2"
    }
    runner_http_latency_1000ms = {
      name              = "runner-http-latency-1000ms"
      description       = "99% of requests as measured from the load balancer metrics are under 1000ms."
      attainment_goal   = 99
      service           = "forms-runner"
      target_group_name = data.aws_lb_target_group.forms_runner_tg.arn_suffix
      threshold         = "1"
    }
  }

  # Submission Delivery SLO definitions
  submission_delivery_slos = {
    submission_delivery_latency = {
      name            = "submission-delivery-latency"
      description     = "99% of submitted submissions are delivered under 5 minutes."
      attainment_goal = 99
      service         = "forms-runner"
      threshold       = "300000"
    }
  }
}

# Availability SLOs
resource "awscc_applicationsignals_service_level_objective" "availability" {
  for_each = local.availability_slos

  name        = each.value.name
  description = each.value.description

  request_based_sli = {
    request_based_sli_metric = {
      total_request_count_metric = [
        {
          id = "cwMetricDenominator"
          metric_stat = {
            metric = {
              namespace   = "AWS/ApplicationELB"
              metric_name = "RequestCount"
              dimensions = [
                {
                  name  = "TargetGroup"
                  value = each.value.target_group_name
                },
                {
                  name  = "LoadBalancer"
                  value = data.aws_lb.forms_lb.arn_suffix
                }
              ]
            }
            period = 60
            stat   = "Sum"
          }
          return_data = true
        }
      ]

      monitored_request_count_metric = {
        bad_count_metric = [
          {
            id = "cwMetricNumerator"
            metric_stat = {
              metric = {
                namespace   = "AWS/ApplicationELB"
                metric_name = "HTTPCode_Target_5XX_Count"
                dimensions = [
                  {
                    name  = "TargetGroup"
                    value = each.value.target_group_name
                  },
                  {
                    name  = "LoadBalancer"
                    value = data.aws_lb.forms_lb.arn_suffix
                  }
                ]
              }
              period = 60
              stat   = "Sum"
            }
            return_data = true
          }
        ]
      }
    }
  }

  goal = merge(local.common_goal_config, {
    attainment_goal = each.value.attainment_goal
  })

  burn_rate_configurations = local.common_burn_rate_configurations

  tags = [
    {
      key   = "Environment"
      value = var.environment_name
    },
    {
      key   = "Service"
      value = each.value.service
    }
  ]
}

# Latency SLOs
resource "awscc_applicationsignals_service_level_objective" "latency" {
  for_each = local.latency_slos

  name        = each.value.name
  description = each.value.description

  request_based_sli = {
    request_based_sli_metric = {
      total_request_count_metric = [
        {
          id = "cwMetricDenominator"
          metric_stat = {
            metric = {
              namespace   = "AWS/ApplicationELB"
              metric_name = "TargetResponseTime"
              dimensions = [
                {
                  name  = "TargetGroup"
                  value = each.value.target_group_name
                },
                {
                  name  = "LoadBalancer"
                  value = data.aws_lb.forms_lb.arn_suffix
                }
              ]
            }
            period = 60
            stat   = "SampleCount"
          }
          return_data = true
        }
      ]

      monitored_request_count_metric = {
        good_count_metric = [
          {
            id = "cwMetricNumerator"
            metric_stat = {
              metric = {
                namespace   = "AWS/ApplicationELB"
                metric_name = "TargetResponseTime"
                dimensions = [
                  {
                    name  = "TargetGroup"
                    value = each.value.target_group_name
                  },
                  {
                    name  = "LoadBalancer"
                    value = data.aws_lb.forms_lb.arn_suffix
                  }
                ]
              }
              period = 60
              stat   = "TC(:${each.value.threshold})"
            }
            return_data = true
          }
        ]
      }
    }
  }

  goal = merge(local.common_goal_config, {
    attainment_goal = each.value.attainment_goal
  })

  burn_rate_configurations = local.common_burn_rate_configurations

  tags = [
    {
      key   = "Environment"
      value = var.environment_name
    },
    {
      key   = "Service"
      value = each.value.service
    }
  ]
}

# Submission Delivery SLOs
resource "awscc_applicationsignals_service_level_objective" "submission_delivery" {
  for_each = local.submission_delivery_slos

  name        = each.value.name
  description = each.value.description

  request_based_sli = {
    request_based_sli_metric = {
      total_request_count_metric = [
        {
          id          = "cwMetricDenominator"
          expression  = "SUM(SEARCH('{Forms,Environment,SubmissionDeliveryMethod} MetricName=\"SubmissionDeliveryLatency\" Environment=\"${var.environment_name}\"', 'SampleCount', 60))"
          period      = 60
          return_data = true
        }
      ]

      monitored_request_count_metric = {
        good_count_metric = [
          {
            id          = "cwMetricNumerator"
            expression  = "SUM(SEARCH('{Forms,Environment,SubmissionDeliveryMethod} MetricName=\"SubmissionDeliveryLatency\" Environment=\"${var.environment_name}\"', 'TC(:${each.value.threshold})', 60))"
            period      = 60
            return_data = true
          }
        ]
      }
    }
  }

  goal = merge(local.common_goal_config, {
    attainment_goal = each.value.attainment_goal
  })

  burn_rate_configurations = local.common_burn_rate_configurations

  tags = [
    {
      key   = "Environment"
      value = var.environment_name
    },
    {
      key   = "Service"
      value = each.value.service
    },
    {
      key   = "Type"
      value = "submission-delivery"
    }
  ]
}

#!/usr/bin/env bash

set -euo pipefail

# This script creates or updates Service Level Objectives (SLOs) for GOV.UK Forms
# using AWS CloudWatch metrics. It is idempotent - it will create SLOs if they don't
# exist, or update them if they do.

environment="${2}"

get_load_balancer_arn() {
    local environment="$1"
    aws elbv2 describe-load-balancers \
        --names "forms-${environment}" \
        --query 'LoadBalancers[0].LoadBalancerArn' \
        --output text
}

# Function to get the TargetGroup ARN
get_target_group_arn() {
    local app="$1"
    local environment="$2"
    aws elbv2 describe-target-groups \
        --names "${app}-${environment}" \
        --query 'TargetGroups[0].TargetGroupArn' \
        --output text
}

# Function to create or update an SLO
create_or_update_slo() {
    local name="$1"
    local description="$2"
    local metric_config="$3"
    local target_value="$4"

    # Check if SLO exists
    local existing_slo
    existing_slo=$(aws application-signals list-service-level-objectives \
        --query "SloSummaries[?Name=='${name}'].Arn" \
        --output text)

    # Common goal configuration for all SLOs
    local goal_config='{
        "Interval": {
            "RollingInterval": {
                "DurationUnit": "DAY",
                "Duration": 28
            }
        },
        "AttainmentGoal": '"${target_value}"',
        "WarningThreshold": 30.0
    }'

    # Common burn rate configuration for all SLOs
    local burn_rate_config='[
        {
            "LookBackWindowMinutes": 5
        },
        {
            "LookBackWindowMinutes": 30
        },
        {
            "LookBackWindowMinutes": 60
        },
        {
            "LookBackWindowMinutes": 360
        },
        {
            "LookBackWindowMinutes": 4320
        }
    ]'

    if [ -z "$existing_slo" ]; then
        echo "Creating SLO: ${name}"
        aws application-signals create-service-level-objective \
            --name "${name}" \
            --description "${description}" \
            --request-based-sli-config "${metric_config}" \
            --goal "${goal_config}" \
            --burn-rate-configurations "${burn_rate_config}" \
            --no-cli-pager
    else
        echo "Updating SLO: ${name}"
        aws application-signals update-service-level-objective \
            --id "${existing_slo}" \
            --description "${description}" \
            --request-based-sli-config "${metric_config}" \
            --goal "${goal_config}" \
            --burn-rate-configurations "${burn_rate_config}" \
            --no-cli-pager
    fi
}

load_balancer_name=$(get_load_balancer_arn "${environment}" | sed 's/.*:loadbalancer\///')
forms_admin_target_group_name=$(get_target_group_arn "forms-admin" "${environment}" | sed 's/.*:targetgroup\//targetgroup\//')
forms_runner_target_group_name=$(get_target_group_arn "forms-runner" "${environment}" | sed 's/.*:targetgroup\//targetgroup\//')

# Admin HTTP Server

# Availability SLO (99% success rate)
create_or_update_slo \
    "admin-http-availability" \
    "99% of requests as measured from the load balancer metrics are successful. Any HTTP status other than 500–599 is considered successful." \
    '{
            "RequestBasedSliMetricConfig": {
                "TotalRequestCountMetric": [
                    {
                        "Id": "cwMetricDenominator",
                        "MetricStat": {
                            "Metric": {
                                "Namespace": "AWS/ApplicationELB",
                                "MetricName": "RequestCount",
                                "Dimensions": [
                                    {
                                        "Name": "TargetGroup",
                                        "Value": "'"${forms_admin_target_group_name}"'"
                                    },
                                    {
                                        "Name": "LoadBalancer",
                                        "Value": "'"${load_balancer_name}"'"
                                    }
                                ]
                            },
                            "Period": 60,
                            "Stat": "Sum"
                        },
                        "ReturnData": true
                    }
                ],
                "MonitoredRequestCountMetric": {
                    "BadCountMetric": [
                        {
                            "Id": "cwMetricNumerator",
                            "MetricStat": {
                                "Metric": {
                                    "Namespace": "AWS/ApplicationELB",
                                    "MetricName": "HTTPCode_Target_5XX_Count",
                                    "Dimensions": [
                                        {
                                            "Name": "TargetGroup",
                                            "Value": "'"${forms_admin_target_group_name}"'"
                                        },
                                        {
                                            "Name": "LoadBalancer",
                                            "Value": "'"${load_balancer_name}"'"
                                        }
                                    ]
                                },
                                "Period": 60,
                                "Stat": "Sum"
                            },
                            "ReturnData": true
                        }
                    ]
                }
            }
            
    }' \
    "99"

# Latency SLO (90% < 400ms)
create_or_update_slo \
    "admin-http-latency-400ms" \
    "90% of requests as measured from the load balancer metrics are under 400ms." \
    '{
            "RequestBasedSliMetricConfig": {
                "TotalRequestCountMetric": [
                    {
                        "Id": "cwMetricDenominator",
                        "MetricStat": {
                            "Metric": {
                                "Namespace": "AWS/ApplicationELB",
                                "MetricName": "TargetResponseTime",
                                "Dimensions": [
                                    {
                                        "Name": "TargetGroup",
                                        "Value": "'"${forms_admin_target_group_name}"'"
                                    },
                                    {
                                        "Name": "LoadBalancer",
                                        "Value": "'"${load_balancer_name}"'"
                                    }
                                ]
                            },
                            "Period": 60,
                            "Stat": "SampleCount"
                        },
                        "ReturnData": true
                    }
                ],
                "MonitoredRequestCountMetric": {
                    "GoodCountMetric": [
                        {
                            "Id": "cwMetricNumerator",
                            "MetricStat": {
                                "Metric": {
                                    "Namespace": "AWS/ApplicationELB",
                                    "MetricName": "TargetResponseTime",
                                    "Dimensions": [
                                        {
                                            "Name": "TargetGroup",
                                            "Value": "'"${forms_admin_target_group_name}"'"
                                        },
                                        {
                                            "Name": "LoadBalancer",
                                            "Value": "'"${load_balancer_name}"'"
                                        }
                                    ]
                                },
                                "Period": 60,
                                "Stat": "TC(:0.4)"
                            },
                            "ReturnData": true
                        }
                    ]
                }
            }
    }' \
    "90"

# Latency SLO (99% < 1000ms)
create_or_update_slo \
    "admin-http-latency-1000ms" \
    "99% of requests as measured from the load balancer metrics are under 1000ms." \
    '{
            "RequestBasedSliMetricConfig": {
                "TotalRequestCountMetric": [
                    {
                        "Id": "cwMetricDenominator",
                        "MetricStat": {
                            "Metric": {
                                "Namespace": "AWS/ApplicationELB",
                                "MetricName": "TargetResponseTime",
                                "Dimensions": [
                                    {
                                        "Name": "TargetGroup",
                                        "Value": "'"${forms_admin_target_group_name}"'"
                                    },
                                    {
                                        "Name": "LoadBalancer",
                                        "Value": "'"${load_balancer_name}"'"
                                    }
                                ]
                            },
                            "Period": 60,
                            "Stat": "SampleCount"
                        },
                        "ReturnData": true
                    }
                ],
                "MonitoredRequestCountMetric": {
                    "GoodCountMetric": [
                        {
                            "Id": "cwMetricNumerator",
                            "MetricStat": {
                                "Metric": {
                                    "Namespace": "AWS/ApplicationELB",
                                    "MetricName": "TargetResponseTime",
                                    "Dimensions": [
                                        {
                                            "Name": "TargetGroup",
                                            "Value": "'"${forms_admin_target_group_name}"'"
                                        },
                                        {
                                            "Name": "LoadBalancer",
                                            "Value": "'"${load_balancer_name}"'"
                                        }
                                    ]
                                },
                                "Period": 60,
                                "Stat": "TC(:1)"
                            },
                            "ReturnData": true
                        }
                    ]
                }
            }
    }' \
    "99"

# Runner HTTP Server

# Availability SLO (99% success rate)
create_or_update_slo \
    "runner-http-availability" \
    "99% of requests as measured from the load balancer metrics are successful. Any HTTP status other than 500–599 is considered successful." \
    '{
        "RequestBasedSliMetricConfig": {
                "TotalRequestCountMetric": [
                    {
                        "Id": "cwMetricDenominator",
                        "MetricStat": {
                            "Metric": {
                                "Namespace": "AWS/ApplicationELB",
                                "MetricName": "RequestCount",
                                "Dimensions": [
                                    {
                                        "Name": "TargetGroup",
                                        "Value": "'"${forms_runner_target_group_name}"'"
                                    },
                                    {
                                        "Name": "LoadBalancer",
                                        "Value": "'"${load_balancer_name}"'"
                                    }
                                ]
                            },
                            "Period": 60,
                            "Stat": "Sum"
                        },
                        "ReturnData": true
                    }
                ],
                "MonitoredRequestCountMetric": {
                    "BadCountMetric": [
                        {
                            "Id": "cwMetricNumerator",
                            "MetricStat": {
                                "Metric": {
                                    "Namespace": "AWS/ApplicationELB",
                                    "MetricName": "HTTPCode_Target_5XX_Count",
                                    "Dimensions": [
                                        {
                                            "Name": "TargetGroup",
                                            "Value": "'"${forms_runner_target_group_name}"'"
                                        },
                                        {
                                            "Name": "LoadBalancer",
                                            "Value": "'"${load_balancer_name}"'"
                                        }
                                    ]
                                },
                                "Period": 60,
                                "Stat": "Sum"
                            },
                            "ReturnData": true
                        }
                    ]
                }
            }
            
    }' \
    "99"

# Latency SLO (90% < 200ms)
create_or_update_slo \
    "runner-http-latency-200ms" \
    "90% of requests as measured from the load balancer metrics are under 200ms." \
    '{
        "RequestBasedSliMetricConfig": {
                "TotalRequestCountMetric": [
                    {
                        "Id": "cwMetricDenominator",
                        "MetricStat": {
                            "Metric": {
                                "Namespace": "AWS/ApplicationELB",
                                "MetricName": "TargetResponseTime",
                                "Dimensions": [
                                    {
                                        "Name": "TargetGroup",
                                        "Value": "'"${forms_runner_target_group_name}"'"
                                    },
                                    {
                                        "Name": "LoadBalancer",
                                        "Value": "'"${load_balancer_name}"'"
                                    }
                                ]
                            },
                            "Period": 60,
                            "Stat": "SampleCount"
                        },
                        "ReturnData": true
                    }
                ],
                "MonitoredRequestCountMetric": {
                    "GoodCountMetric": [
                        {
                            "Id": "cwMetricNumerator",
                            "MetricStat": {
                                "Metric": {
                                    "Namespace": "AWS/ApplicationELB",
                                    "MetricName": "TargetResponseTime",
                                    "Dimensions": [
                                        {
                                            "Name": "TargetGroup",
                                            "Value": "'"${forms_runner_target_group_name}"'"
                                        },
                                        {
                                            "Name": "LoadBalancer",
                                            "Value": "'"${load_balancer_name}"'"
                                        }
                                    ]
                                },
                                "Period": 60,
                                "Stat": "TC(:0.4)"
                            },
                            "ReturnData": true
                        }
                    ]
                }
            }
    }' \
    "90"

# Latency SLO (99% < 1000ms)
create_or_update_slo \
    "runner-http-latency-1000ms" \
    "99% of requests as measured from the load balancer metrics are under 1000ms." \
    '{
            "RequestBasedSliMetricConfig": {
                "TotalRequestCountMetric": [
                    {
                        "Id": "cwMetricDenominator",
                        "MetricStat": {
                            "Metric": {
                                "Namespace": "AWS/ApplicationELB",
                                "MetricName": "TargetResponseTime",
                                "Dimensions": [
                                    {
                                        "Name": "TargetGroup",
                                        "Value": "'"${forms_runner_target_group_name}"'"
                                    },
                                    {
                                        "Name": "LoadBalancer",
                                        "Value": "'"${load_balancer_name}"'"
                                    }
                                ]
                            },
                            "Period": 60,
                            "Stat": "SampleCount"
                        },
                        "ReturnData": true
                    }
                ],
                "MonitoredRequestCountMetric": {
                    "GoodCountMetric": [
                        {
                            "Id": "cwMetricNumerator",
                            "MetricStat": {
                                "Metric": {
                                    "Namespace": "AWS/ApplicationELB",
                                    "MetricName": "TargetResponseTime",
                                    "Dimensions": [
                                        {
                                            "Name": "TargetGroup",
                                            "Value": "'"${forms_runner_target_group_name}"'"
                                        },
                                        {
                                            "Name": "LoadBalancer",
                                            "Value": "'"${load_balancer_name}"'"
                                        }
                                    ]
                                },
                                "Period": 60,
                                "Stat": "TC(:1)"
                            },
                            "ReturnData": true
                        }
                    ]
                }
            }

    }' \
    "99"
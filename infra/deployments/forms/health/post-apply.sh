#!/usr/bin/env bash
# shellcheck disable=SC2001

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

# Function to get metric configuration from template
get_metric_config() {
    local template_file="$1"
    local target_group_name="$2"
    local load_balancer_name="$3"
    local threshold="${4:-}"
    
    # Read the template file
    local config
    config=$(cat "$(dirname "$0")/${template_file}")
    
    # Replace placeholders with actual values
    # Use different delimiter for sed to avoid issues with slashes in the values
    config=$(echo "$config" | sed "s|\${target_group_name}|${target_group_name}|g")
    config=$(echo "$config" | sed "s|\${load_balancer_name}|${load_balancer_name}|g")
    config=$(echo "$config" | sed "s|\${environment}|${environment}|g")
    
    # Replace threshold if provided
    if [ -n "$threshold" ]; then
        config=$(echo "$config" | sed "s|\${threshold}|${threshold}|g")
    fi
    
    echo "$config"
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
admin_availability_config=$(get_metric_config "slos/availability-slo-metric-config.json" "${forms_admin_target_group_name}" "${load_balancer_name}")
create_or_update_slo \
    "admin-http-availability" \
    "99% of requests as measured from the load balancer metrics are successful. Any HTTP status other than 500–599 is considered successful." \
    "${admin_availability_config}" \
    "99"

# Latency SLO (90% < 400ms)
admin_latency_400ms_config=$(get_metric_config "slos/latency-slo-metric-config.json" "${forms_admin_target_group_name}" "${load_balancer_name}" "0.4")
create_or_update_slo \
    "admin-http-latency-400ms" \
    "90% of requests as measured from the load balancer metrics are under 400ms." \
    "${admin_latency_400ms_config}" \
    "90"

# Latency SLO (99% < 1000ms)
admin_latency_1000ms_config=$(get_metric_config "slos/latency-slo-metric-config.json" "${forms_admin_target_group_name}" "${load_balancer_name}" "1")
create_or_update_slo \
    "admin-http-latency-1000ms" \
    "99% of requests as measured from the load balancer metrics are under 1000ms." \
    "${admin_latency_1000ms_config}" \
    "99"

# Runner HTTP Server

# Availability SLO (99% success rate)
runner_availability_config=$(get_metric_config "slos/availability-slo-metric-config.json" "${forms_runner_target_group_name}" "${load_balancer_name}")
create_or_update_slo \
    "runner-http-availability" \
    "99% of requests as measured from the load balancer metrics are successful. Any HTTP status other than 500–599 is considered successful." \
    "${runner_availability_config}" \
    "99"

# Latency SLO (90% < 200ms)
runner_latency_200ms_config=$(get_metric_config "slos/latency-slo-metric-config.json" "${forms_runner_target_group_name}" "${load_balancer_name}" "0.2")
create_or_update_slo \
    "runner-http-latency-200ms" \
    "90% of requests as measured from the load balancer metrics are under 200ms." \
    "${runner_latency_200ms_config}" \
    "90"

# Latency SLO (99% < 1000ms)
runner_latency_1000ms_config=$(get_metric_config "slos/latency-slo-metric-config.json" "${forms_runner_target_group_name}" "${load_balancer_name}" "1")
create_or_update_slo \
    "runner-http-latency-1000ms" \
    "99% of requests as measured from the load balancer metrics are under 1000ms." \
    "${runner_latency_1000ms_config}" \
    "99"

# Submission Delivery Pipeline

# Submission Delivery Latency SLO (99% < 5mins)
submission_delivery_latency_config=$(get_metric_config "slos/submission-delivery-latency-slo-metric-config.json" "${forms_runner_target_group_name}" "${load_balancer_name}" "300000")
create_or_update_slo \
    "submission-delivery-latency" \
    "99% of submitted submissions are delivered under 5 minutes." \
    "${submission_delivery_latency_config}" \
    "99"

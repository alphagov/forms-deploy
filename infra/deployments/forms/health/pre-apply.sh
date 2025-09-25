#!/usr/bin/env bash
# shellcheck disable=SC2001

set -euo pipefail

# This script imports existing Application Signals SLOs into Terraform state
# before applying changes. This prevents duplicate resources from being created.

src_dir="${3}"
tfvars_arguments="${4}"

echo "Starting SLO import process..."

# Define the SLO mappings: terraform_resource_name -> aws_slo_name
declare -A slo_mappings=(
    ["awscc_applicationsignals_service_level_objective.availability[\"admin_http_availability\"]"]="admin-http-availability"
    ["awscc_applicationsignals_service_level_objective.availability[\"runner_http_availability\"]"]="runner-http-availability"
    ["awscc_applicationsignals_service_level_objective.latency[\"admin_http_latency_400ms\"]"]="admin-http-latency-400ms"
    ["awscc_applicationsignals_service_level_objective.latency[\"admin_http_latency_1000ms\"]"]="admin-http-latency-1000ms"
    ["awscc_applicationsignals_service_level_objective.latency[\"runner_http_latency_200ms\"]"]="runner-http-latency-200ms"
    ["awscc_applicationsignals_service_level_objective.latency[\"runner_http_latency_1000ms\"]"]="runner-http-latency-1000ms"
    ["awscc_applicationsignals_service_level_objective.submission_delivery[\"submission_delivery_latency\"]"]="submission-delivery-latency"
)

# Get all existing resources in Terraform state
echo "Fetching existing Terraform state..."
existing_terraform_resources=$(terraform -chdir="${src_dir}" state list 2>/dev/null | grep "awscc_applicationsignals_service_level_objective" || true)

# Get all existing SLOs from AWS
echo "Fetching existing SLOs from AWS..."
existing_aws_slos=$(aws application-signals list-service-level-objectives \
    --query "SloSummaries[*].[Name,Arn]" \
    --output text 2>/dev/null || true)

# Function to check if resource exists in Terraform state
resource_exists_in_state() {
    local resource_name="$1"
    echo "$existing_terraform_resources" | grep -Fxq "$resource_name"
}

# Function to get SLO ARN by name
get_slo_arn() {
    local slo_name="$1"
    echo "$existing_aws_slos" | awk -v name="$slo_name" '$1 == name {print $2}' | head -n1
}

# Function to import SLO into Terraform state
import_slo() {
    local terraform_resource="$1"
    local slo_arn="$2"
    local slo_name="$3"

    echo "  Importing ${slo_name} into Terraform state..."
    # shellcheck disable=SC2086
    if terraform -chdir="${src_dir}" import ${tfvars_arguments} "$terraform_resource" "$slo_arn"; then
        echo "    Successfully imported ${slo_name}"
    else
        echo "    Failed to import ${slo_name}"
        return 1
    fi
}

imported_count=0
skipped_count=0
missing_count=0

# Process each SLO mapping
for terraform_resource in "${!slo_mappings[@]}"; do
    slo_name="${slo_mappings[$terraform_resource]}"
    echo "Processing SLO: ${slo_name}"

    # Check if resource already exists in Terraform state
    if resource_exists_in_state "$terraform_resource"; then
        echo "    Resource ${terraform_resource} already exists in state, skipping import"
        skipped_count=$((skipped_count + 1))
        continue
    fi

    # Get the ARN of the existing SLO from AWS
    slo_arn=$(get_slo_arn "$slo_name")

    if [[ -z "$slo_arn" || "$slo_arn" == "None" ]]; then
        echo "    SLO ${slo_name} not found in AWS, will be created during apply"
        missing_count=$((missing_count + 1))
        continue
    fi

    # Import the SLO into Terraform state
    if import_slo "$terraform_resource" "$slo_arn" "$slo_name"; then
        imported_count=$((imported_count + 1))
    else
        echo "    Import failed for ${slo_name}, continuing with other SLOs..."
    fi
done

echo
echo "Import summary:"
echo "  Imported: ${imported_count} SLO(s)"
echo "  Skipped (already in state): ${skipped_count} SLO(s)"
echo "  Missing (will be created): ${missing_count} SLO(s)"
echo
echo "SLO import process completed."

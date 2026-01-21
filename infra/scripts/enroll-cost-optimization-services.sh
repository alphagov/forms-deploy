#!/usr/bin/env bash

set -euo pipefail

# This script enrolls the AWS account in Cost Optimization Hub and Compute Optimizer
# It runs automatically after terraform apply completes successfully
#
# IMPORTANT: This logic should ideally live in Terraform resources within the
# infra/modules/account module. However, aws_costoptimizationhub_enrollment_status
# has drift issues, and both services are managed here for consistency as they are
# closely related AWS cost optimization features.
# See infra/modules/account/main.tf for more details and the commented-out resources.
#
# When the Cost Optimization Hub drift issue is resolved, this script should be removed
# and both resources in the module should be uncommented.
# See: https://github.com/hashicorp/terraform-provider-aws/issues/39520

echo "Checking Cost Optimization Hub enrollment status..."

# Get current account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Check current enrollment status for this account
STATUS=$(aws cost-optimization-hub list-enrollment-statuses --region us-east-1 --query "items[?accountId=='${ACCOUNT_ID}'].status" --output text 2>/dev/null || echo "None")

if [ "${STATUS}" = "Active" ]; then
    echo "✓ Already enrolled in Cost Optimization Hub"
else
    echo "Enrolling account in Cost Optimization Hub..."
    if aws cost-optimization-hub update-enrollment-status \
        --status Active \
        --region us-east-1; then
        echo "✓ Successfully enrolled in Cost Optimization Hub"
    else
        echo "⚠ Failed to enroll in Cost Optimization Hub"
        exit 1
    fi
fi

echo "Checking Cost Optimization Hub savings estimation mode..."

# Check current savings estimation mode preference
SAVINGS_MODE=$(aws cost-optimization-hub get-preferences --region us-east-1 --query 'savingsEstimationMode' --output text 2>/dev/null || echo "Unknown")

if [ "${SAVINGS_MODE}" = "AfterDiscounts" ]; then
    echo "✓ Savings estimation mode already set to AfterDiscounts"
else
    echo "Setting savings estimation mode to AfterDiscounts..."
    if aws cost-optimization-hub update-preferences \
        --savings-estimation-mode AfterDiscounts \
        --region us-east-1; then
        echo "✓ Successfully set savings estimation mode to AfterDiscounts"
    else
        echo "⚠ Failed to set savings estimation mode"
        exit 1
    fi
fi

echo "Checking Compute Optimizer enrollment status..."

# Check current enrollment status
CO_STATUS=$(aws compute-optimizer get-enrollment-status --query 'status' --output text 2>/dev/null || echo "None")

if [ "${CO_STATUS}" = "Active" ]; then
    echo "✓ Already enrolled in Compute Optimizer"
else
    echo "Enrolling account in Compute Optimizer..."
    if aws compute-optimizer update-enrollment-status \
        --status Active; then
        echo "✓ Successfully enrolled in Compute Optimizer"
    else
        echo "⚠ Failed to enroll in Compute Optimizer"
        exit 1
    fi
fi

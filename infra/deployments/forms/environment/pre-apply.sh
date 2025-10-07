#!/bin/bash
set -e

# Pre-apply script for environment deployment
# This script handles the transition of the internal zone management to the account deployment

ENVIRONMENT_NAME="$2"
SRC_DIR="$3"
TFVARS_ARGS="$4"

# Build the root domain based on environment
case "$ENVIRONMENT_NAME" in
"production")
    ROOT_DOMAIN="forms.service.gov.uk"
    ;;
*)
    ROOT_DOMAIN="${ENVIRONMENT_NAME}.forms.service.gov.uk"
    ;;
esac

echo "Removing internal zone from environment state (it's now managed by the account deployment)..."

# Remove the old zone resource from state (it's now a data source referencing the account-managed zone)
terraform -chdir="$SRC_DIR" state rm module.environment.aws_route53_zone.private_internal 2>/dev/null ||
    echo "No internal zone resource found in terraform state to remove"

echo "Checking for existing VPC associations..."

# Get the internal zone ID from AWS
ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name "internal.${ROOT_DOMAIN}" --query "HostedZones[?Name==\`internal.${ROOT_DOMAIN}.\` && Config.PrivateZone==\`true\`].Id" --output text 2>/dev/null | sed 's|/hostedzone/||' || echo "")

if [ -n "$ZONE_ID" ]; then
    echo "Found internal zone: ${ZONE_ID}"

    # Get the VPC ID - the VPC is named "forms-{environment}"
    VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=forms-${ENVIRONMENT_NAME}" --query "Vpcs[0].VpcId" --output text 2>/dev/null || echo "")

    if [ -n "$VPC_ID" ] && [ "$VPC_ID" != "None" ]; then
        echo "Found VPC: ${VPC_ID}"

        # Check if zone association already exists in terraform state
        if ! terraform -chdir="$SRC_DIR" state show module.environment.aws_route53_zone_association.private_internal >/dev/null 2>&1; then
            echo "Importing zone association..."
            # shellcheck disable=SC2086
            terraform -chdir="$SRC_DIR" import ${TFVARS_ARGS} module.environment.aws_route53_zone_association.private_internal "${ZONE_ID}:${VPC_ID}" || true
        fi
    else
        echo "VPC not found, skipping association imports"
    fi
else
    echo "Internal zone not found, skipping association imports"
fi

echo "Environment pre-apply completed"

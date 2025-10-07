#!/bin/bash
set -e

# Pre-apply script to import the internal zone if it exists
# This script checks if the internal zone exists in AWS and imports it
# to the account state before applying, so we don't get conflicts

ENVIRONMENT_NAME="$2"
SRC_DIR="$3"
TFVAR_ARGS="$4"

# Build the root domain based on environment
case "$ENVIRONMENT_NAME" in
"production")
    ROOT_DOMAIN="forms.service.gov.uk"
    ;;
*)
    ROOT_DOMAIN="${ENVIRONMENT_NAME}.forms.service.gov.uk"
    ;;
esac

echo "Checking if internal zone is already in terraform state..."

# Check if the zone is already in our state
if terraform -chdir="$SRC_DIR" state show aws_route53_zone.private_internal >/dev/null 2>&1; then
    echo "Internal zone already exists in terraform state, skipping import"
    exit 0
fi

echo "Checking if internal zone exists for ${ROOT_DOMAIN}..."

# Check if the internal zone exists in AWS
ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name "internal.${ROOT_DOMAIN}" --query "HostedZones[?Name==\`internal.${ROOT_DOMAIN}.\` && Config.PrivateZone==\`true\`].Id" --output text 2>/dev/null | sed 's|/hostedzone/||' || echo "")

if [ -n "$ZONE_ID" ]; then
    echo "Found existing internal zone in AWS: ${ZONE_ID}"
    echo "Importing zone to account state..."

    # Import the zone to the account state
    # shellcheck disable=SC2086
    terraform -chdir="$SRC_DIR" import ${TFVAR_ARGS} aws_route53_zone.private_internal "${ZONE_ID}" || true

    echo "Zone import completed"
else
    echo "No existing internal zone found, proceeding with normal apply"
fi

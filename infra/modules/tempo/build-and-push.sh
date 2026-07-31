#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

valid_image_names=("grafana" "tempo" "prometheus")

image_to_build="${1:-}"
if [[ ! " ${valid_image_names[*]} " =~ .*\ ${image_to_build}\ .* ]]; then
    echo "Invalid image name: ${image_to_build}. Valid options are: ${valid_image_names[*]}"
    exit 1
fi

eval "$(gds aws forms-dev-admin -e)"

export REGION="${REGION:-eu-west-2}"
export ACCOUNT_ID="${ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}"

aws ecr get-login-password --region "${REGION}" |
    docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

if [ "${image_to_build}" == "prometheus" ]; then
    docker pull --platform linux/arm64 prom/prometheus:latest
    docker tag prom/prometheus:latest "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/tempo-poc-prometheus:latest"
    docker push "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/tempo-poc-prometheus:latest"
else
    docker buildx build --platform linux/arm64 \
        -t "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/tempo-poc-${image_to_build}:latest" \
        --push \
        "docker/${image_to_build}"
fi

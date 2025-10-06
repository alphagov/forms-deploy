#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

configured_environments=()
for f in "${SCRIPT_DIR}"/../tfvars/backends/*.tfvars; do
    configured_environments+=("$(basename "$f" .tfvars)")
done

function usage() {
    env_list=$(
        IFS=\|
        echo "${configured_environments[*]}"
    )
    echo "Usage: $0 <environment>"
    echo "  environment: $env_list"
    exit 1
}

if [ "$#" -ne 1 ]; then
    usage
fi
environment="$1"
if [[ ! " ${configured_environments[*]} " =~ ${environment} ]]; then
    echo "Invalid environment: $environment"
    usage
fi

VAR_FILE="${SCRIPT_DIR}/../tfvars/backends/${environment}.tfvars"

if ! command -v hcl2json &>/dev/null; then
    echo "hcl2json could not be found, please install it."
    exit 1
fi
BUCKET_NAME=$(hcl2json "${VAR_FILE}" | jq -r '.bucket')

export TF_DATA_DIR="${SCRIPT_DIR}/.terraform"

function terraform_init() {
    local terraform_directory="${1}"
    shift
    echo -n "Terraform init..."
    if terraform -chdir="${terraform_directory}" init -upgrade "${@}" &>/dev/null; then
        echo " done"
        return 0
    fi
    echo " failed, removing TF_DATA_DIR and retrying..."
    rm -rf "${TF_DATA_DIR}"
    terraform -chdir="${terraform_directory}" init -upgrade "${@}"
}

terraform_init "${SCRIPT_DIR}" -backend-config="bucket=${BUCKET_NAME}"
terraform -chdir="${SCRIPT_DIR}" apply -var "bucket_name=${BUCKET_NAME}"

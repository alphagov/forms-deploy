#!/usr/bin/env bash
#
# record-deployment-metadata.sh
#
# Purpose:
#   Records the current Git commit SHA and branch as deployment metadata in an AWS SSM parameter.
#
# Usage:
#   This script is called automatically after 'terraform apply' for 'deploy' or 'integration' deployments.
#   It requires the following arguments:
#     -d <deployment>      # Deployment type: 'deploy' or 'integration'
#     -r <terraform_root>  # Terraform root module name
#     -e <environment>     # Environment name
#
# SSM Parameters Created:
#   /terraform/last_applied/${DEPLOYMENT}/${TF_ROOT}
#   The parameter value is a JSON object: { "sha": "<git-sha>", "branch": "<git-branch>" }
#
# Prerequisites:
#   - Must be run inside a git repository
#   - AWS CLI must be configured with credentials to access SSM
#   - 'jq' must be installed and available in PATH
#

set -euo pipefail

while getopts "d:r:e:" opt; do
    case "${opt}" in
    d)
        DEPLOYMENT="${OPTARG}"
        ;;
    r)
        TF_ROOT="${OPTARG}"
        ;;
    e)
        ENVIRONMENT="${OPTARG}"
        ;;
    *)
        echo "Usage: $0 -d <deployment> -r <terraform_root> -e <environment>" >&2
        exit 1
        ;;
    esac
done

# Check all required options were set
if [[ -z "${DEPLOYMENT:-}" ]] || [[ -z "${TF_ROOT:-}" ]] || [[ -z "${ENVIRONMENT:-}" ]]; then
    echo "Usage: $0 -d <deployment> -r <terraform_root> -e <environment>" >&2
    exit 1
fi

function _log() {
    local msg="$1"
    echo "[record-deployment-metadata] $msg"
}

function _log_error() {
    local msg="$1"
    _log "ERROR: $msg" >&2
}

function _get_head_sha() {
    git log -1 --pretty=format:%H
}

function _get_head_branch() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$branch" != "HEAD" ]]; then
        echo "$branch"
    else
        # Try to get tag if present
        local tag
        tag=$(git describe --tags --exact-match 2>/dev/null || true)
        if [[ -n "$tag" ]]; then
            echo "detached@tag:$tag"
        else
            local sha
            sha=$(git rev-parse HEAD)
            echo "detached@commit:$sha"
        fi
    fi
}

function build_parameter_value() {
    local head_sha
    head_sha="$(_get_head_sha)"
    local head_branch
    head_branch="$(_get_head_branch)"
    jq -cn --arg sha "$head_sha" --arg branch "$head_branch" '{sha: $sha, branch: $branch}'
}

if [[ "$DEPLOYMENT" != "integration" && "$DEPLOYMENT" != "deploy" ]]; then
    _log_error "Deployment must be 'integration' or 'deploy'"
    exit 1
fi

# Check for required dependencies
if ! command -v jq &>/dev/null; then
    _log_error "jq is required but not installed"
    exit 1
fi
if ! command -v aws &>/dev/null; then
    _log_error "AWS CLI is required but not installed"
    exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    _log_error "Not in a git repository"
    exit 1
fi

SSM_PARAMETER_NAME="/terraform/last_applied/${DEPLOYMENT}/${TF_ROOT}"

PARAMETER_VALUE=$(build_parameter_value)

CURRENT_PARAMETER_VALUE=$(aws ssm get-parameter --name "$SSM_PARAMETER_NAME" --query 'Parameter.Value' --output text 2>/dev/null || echo "")
if [[ "$CURRENT_PARAMETER_VALUE" == "$PARAMETER_VALUE" ]]; then
    _log "Parameter $SSM_PARAMETER_NAME is already up to date. Skipping update."
    exit 0
fi

if ! aws ssm put-parameter \
    --name "$SSM_PARAMETER_NAME" \
    --type "String" \
    --value "$PARAMETER_VALUE" \
    --description "Last applied Git SHA and branch for ${DEPLOYMENT} deployment at Terraform root ${TF_ROOT}" \
    --overwrite >/dev/null; then
    _log_error "Failed to update SSM parameter $SSM_PARAMETER_NAME"
    exit 1
fi

if ! aws ssm add-tags-to-resource \
    --resource-type "Parameter" \
    --resource-id "$SSM_PARAMETER_NAME" \
    --tags Key=Environment,Value="$ENVIRONMENT" Key=Deployment,Value="${DEPLOYMENT}/${TF_ROOT}" Key=UpdatedBy,Value="record-deployment-metadata" Key=Applier,Value="$(whoami)" >/dev/null; then
    _log_error "Failed to add tags to SSM parameter $SSM_PARAMETER_NAME"
    exit 1
fi

_log "Recorded deployment metadata to SSM parameter $SSM_PARAMETER_NAME"

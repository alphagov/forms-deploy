#!/usr/bin/env bash

set -euo pipefail

# Path constants
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
root_dir="$(realpath "${script_dir}/../")"
readonly root_dir
deployments_dir="$(realpath "${script_dir}/../infra/deployments/")"
readonly deployments_dir

# Plugin cache setup
TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-${root_dir}/.terraform-plugin-cache}"
mkdir -p "${TF_PLUGIN_CACHE_DIR}"
export TF_PLUGIN_CACHE_DIR

action=""
deployment=""
environment=""
tf_root=""
lock_id=""

validate_deployment() {
    [[ -n "${deployment}" ]] || { echo "Error: Deployment not set" >&2 && exit 1; }
}
validate_environment() {
    [[ -n "${environment}" ]] || { echo "Error: Environment not set" >&2 && exit 1; }
}
validate_lock_id() {
    [[ -n "${lock_id}" ]] || { echo "Error: Lock ID not set" >&2 && exit 1; }
}

validate_terraform() {
    if ! command -v terraform &>/dev/null; then
        echo "Error: Terraform is not installed or not in PATH" >&2
        exit 1
    fi
    validate_source_dir
    validate_deployment
    validate_environment
}

usage() {
    cat <<EOF >&2
Usage: $0 -a <action> -d <deployment> -e <environment> [-r <terraform_root>] [-l <lock_id>]

Actions: apply|init|plan|validate|unlock|shell|clear-plugin-cache

This helper script invokes Terraform in the correct manner, given the deployment,
environment, and root. It encodes the different arguments required for different
pieces of Terraform, so that operators don't have to know and remember the exact
combination for a successful application of any given root module.
EOF
    exit 1
}

# Parse args
while getopts "a:d:e:r:l:" opt; do
    case "${opt}" in
    a)
        action="${OPTARG}"
        ;;
    d)
        deployment="${OPTARG}"
        ;;
    e)
        environment="${OPTARG}"
        ;;
    r)
        tf_root="${OPTARG}"
        ;;

    l)
        lock_id="${OPTARG}"
        ;;

    *)
        usage
        ;;
    esac

done

# Set source directory and validate
src_dir="${deployments_dir}/${deployment}/${tf_root}"

validate_source_dir() {
    if [ ! -d "${src_dir}" ]; then
        echo "Error: Source directory does not exist: ${src_dir}" >&2
        exit 1
    fi
}

# Run hook script with error handling
run_hook_script() {
    local hook_type="$1"
    local hook_script="${src_dir}/${hook_type}.sh"
    local hook_label
    hook_label="$(echo "${hook_type}" | tr '[:lower:]' '[:upper:]')"

    local tfvars_arguments
    tfvars_arguments="$(_build_terraform_vars_file_args)"

    if [ -e "${hook_script}" ]; then
        echo "${hook_label}: Running ${hook_type} script ${hook_script}"
        if ! bash "${hook_script}" "${root_dir}" "${environment}" "${src_dir}" "${tfvars_arguments}" | sed "s/^/[${hook_label}] /"; then
            echo "${hook_label}: Script failed" >&2
            exit 1
        fi
    else
        echo "${hook_label}: No ${hook_type} script found at ${hook_script}"
    fi
}

# Handlers
pre_init() {
    run_hook_script "pre-init"
}

tf_init() {
    extra_args=""

    if [ "${deployment}" == "forms" ]; then
        extra_args="${extra_args} -backend-config ${deployments_dir}/forms/account/tfvars/backends/${environment}.tfvars"
    fi

    if [ "${deployment}" == "integration" ]; then
        extra_args="${extra_args} -backend-config ${deployments_dir}/integration/tfvars/backends/integration.tfvars"
    fi

    # shellcheck disable=SC2086
    terraform \
        -chdir="${src_dir}" \
        init \
        -reconfigure \
        -upgrade \
        ${extra_args}
}

pre_apply() {
    run_hook_script "pre-apply"
}

# Build terraform var-file arguments based on deployment and environment
_build_terraform_vars_file_args() {
    local tfvars_files=()
    local forms_account_dir="${deployments_dir}/forms/account/tfvars"
    local forms_tfvars_dir="${deployments_dir}/forms/tfvars"
    local integration_tfvars_dir="${deployments_dir}/integration/tfvars"

    # Build tfvars file list based on deployment and root
    case "${deployment}" in
    "forms")
        if [ "${tf_root}" == "account" ]; then
            # forms/account uses different vars files
            tfvars_files+=(
                "${forms_account_dir}/${environment}.tfvars"
                "${forms_account_dir}/backends/${environment}.tfvars"
            )
        else
            # Other forms roots use shared forms vars plus backend
            tfvars_files+=(
                "${forms_tfvars_dir}/${environment}.tfvars"
                "${forms_account_dir}/backends/${environment}.tfvars"
            )
        fi
        ;;
    "integration")
        tfvars_files+=(
            "${integration_tfvars_dir}/integration.tfvars"
            "${integration_tfvars_dir}/backends/integration.tfvars"
        )
        ;;
    esac

    # Add deployment+root specific vars
    case "${deployment}+${tf_root}" in
    "forms+pipelines")
        tfvars_files+=("${deployments_dir}/forms/pipelines/tfvars/${environment}.tfvars")
        ;;
    esac

    # Convert array to terraform arguments
    local tfvars_args=""
    for tfvars_file in "${tfvars_files[@]}"; do
        tfvars_args="${tfvars_args} -var-file ${tfvars_file}"
    done

    echo "${tfvars_args}"
}

# Execute terraform plan or apply with appropriate var files and options
tf_plan_apply() {
    action="$1"
    extra_args="$(_build_terraform_vars_file_args)"

    if [ "${FORMS_TF_AUTO_APPROVE:-false}" = true ] && [ "${action}" = "apply" ]; then
        echo "FORMS_TF_AUTO_APPROVE was set to true"
        echo "Terraform will be automatically applied"
        extra_args="${extra_args} -auto-approve"
    fi
    # shellcheck disable=SC2086
    terraform \
        -chdir="${src_dir}" \
        ${action} \
        ${extra_args}
    tf_exit_code=$?

    # Terraform only gives an exit code of 0 on a successful run
    if [ ${tf_exit_code} = 0 ] && [ "${action}" = "apply" ]; then
        echo "" # make some space before post apply
        post_apply
    fi
}

tf_validate() {
    terraform \
        -chdir="${src_dir}" \
        validate
}

tf_unlock() {
    terraform \
        -chdir="${src_dir}" \
        force-unlock \
        "${lock_id}"
}

# Run post-apply tasks including AWS Shield subscription and hook scripts
post_apply() {
    # Run AWS Shield subscription for account deployments
    case "${deployment}+${tf_root}" in
    "forms+account" | "deploy+account" | "integration+account")
        echo "POST-APPLY: Checking AWS Shield subscription"
        "${script_dir}"/../infra/scripts/subscribe-to-aws-shield-advanced.sh
        ;;
    esac

    # Record SHA + branch metadata to SSM for deploy and integration deployments
    case "${deployment}" in
    "deploy" | "integration")
        echo "POST-APPLY: Recording deployment metadata"
        "${script_dir}"/../infra/scripts/record-deployment-metadata.sh -e "${environment}" -d "${deployment}" -r "${tf_root}"
        ;;
    esac

    run_hook_script "post-apply"
}

shell() {
    pushd "${src_dir}" >/dev/null || exit 1
    echo ""
    echo "Starting interactive shell in ${environment} environment, ${deployment}/${tf_root} deployment."
    echo ""
    echo "WARNING: terraform commands will act on the above environment/deployment's state!"
    echo ""
    echo "Terraform variable file arguments for this environment/deployment are:"
    echo "  $(_build_terraform_vars_file_args)"
    echo ""
    echo "To exit, type 'exit' or press Ctrl-D"
    echo ""
    $SHELL -i
    popd >/dev/null || exit 1
}

clear-plugin-cache() {
    echo "Clearing Terraform plugin cache at ${TF_PLUGIN_CACHE_DIR}"
    # Safety check: ensure TF_PLUGIN_CACHE_DIR is not empty or /
    if [[ -z "${TF_PLUGIN_CACHE_DIR}" || "${TF_PLUGIN_CACHE_DIR}" == "/" ]]; then
        echo "Refusing to clear plugin cache: TF_PLUGIN_CACHE_DIR is empty or /" >&2
        exit 1
    fi
    # Use find to safely delete all contents
    find "${TF_PLUGIN_CACHE_DIR}" -mindepth 1 -not -name ".gitkeep" -exec rm -rf -- {} +
}

case "${action}" in
apply)
    validate_terraform
    pre_apply
    tf_plan_apply "apply"
    ;;
init)
    validate_terraform
    pre_init
    tf_init
    ;;
plan)
    validate_terraform
    pre_apply # We use pre_apply here so that a plan and application look as similar as possible
    tf_plan_apply "plan"
    ;;

validate)
    validate_terraform
    tf_validate
    ;;

unlock)
    validate_terraform
    validate_lock_id
    tf_unlock
    ;;

shell)
    validate_terraform
    shell
    ;;
clear-plugin-cache)
    clear-plugin-cache
    ;;
*)
    usage
    ;;
esac

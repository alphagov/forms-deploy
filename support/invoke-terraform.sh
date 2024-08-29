#!/usr/bin/env bash

set -euo pipefail

script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
root_dir="$(realpath "${script_dir}/../")"
deployments_dir="$(realpath "${script_dir}/../infra/deployments/")"

action=""
deployment=""
environment=""
tf_root=""
lock_id=""

usage() {
    cat <<EOF >&2
Usage: $0 -a apply|init|plan|validate|unlock -d deployment -e environment [-r terraform_root] [-l lock_id]

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
            [[ $action == "apply" || $action == "init" || $action == "plan" || $action == "validate" || $action == "unlock" ]] ||  usage
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

shift $((OPTIND-1))
# Validate require args were set
if [ -z "${action}" ] || [ -z "${deployment}" ] || [ -z "${environment}" ]; then
    usage
fi

if [[ $action == "unlock" ]] && [ -z "${lock_id}" ]; then
    >&2 echo "Lock id must be set"
    usage
fi

# Set source directory
src_dir="${deployments_dir}/${deployment}/${tf_root}"

## Consider special combinations of deployment, environment, and root
case "${deployment}+${tf_root}" in
    "account+account")
        # The `account` deployment is its own root, so doesn't need an extra directory appending
        src_dir="${deployments_dir}/${deployment}"
        ;;
esac

# Handlers
pre_init() {
  pre_init_script="${src_dir}/pre-init.sh"
  if [ -e "${pre_init_script}" ]; then
    echo "PRE-INIT: Running pre-init script ${pre_init_script}"
    set -e
    bash "${pre_init_script}" "${root_dir}" "${environment}"| sed  's/^/[PRE-INIT] /'
    set +e
  else
    echo "PRE-INIT: No pre-init script found at ${pre_init_script}"
  fi
}

init(){
    extra_args=""

    if [ "${deployment}" == "forms" ] || [ "${deployment}" == "account" ]; then
        extra_args="${extra_args} -backend-config ${deployments_dir}/account/tfvars/backends/${environment}.tfvars"
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
  pre_apply_script="${src_dir}/pre-apply.sh"
  if [ -e "${pre_apply_script}" ]; then
    echo "PRE-APPLY: Running pre-apply script ${pre_apply_script}"
    set -e
    bash "${pre_apply_script}" "${root_dir}" "${environment}" | sed  's/^/[PRE-APPLY] /'
    set +e
  else
    echo "PRE-APPLY: No pre-apply script found at ${pre_apply_script}"
  fi
}

plan_apply(){
    action="$1"
    extra_args="-var-file ${deployments_dir}/account/tfvars/backends/${environment}.tfvars"

    if [ "${deployment}" == "forms" ]; then
        extra_args="${extra_args} -var-file ${deployments_dir}/forms/tfvars/${environment}.tfvars";
    fi

    if [ "${deployment}" == "account" ]; then
        extra_args="${extra_args} -var-file ${deployments_dir}/account/tfvars/${environment}.tfvars";
    fi

    case "${deployment}+${tf_root}" in
        "forms+pipelines")
            extra_args="${extra_args} -var-file ${deployments_dir}/forms/pipelines/tfvars/${environment}.tfvars";
            ;;
    esac

    if [ "${FORMS_TF_AUTO_APPROVE:-false}" = true ] && [ "${action}" = "apply" ]; then
        echo "FORMS_TF_AUTO_APPROVE was set to true"
        echo "Terraform will be automatically applied"
        extra_args="${extra_args} -auto-approve";
    fi
    # shellcheck disable=SC2086
    terraform \
		-chdir="${src_dir}" \
		${action} \
		${extra_args}
    tf_exit_code=$?

    # Terraform only gives an exit code of 0 on a successful run
    if [ ${tf_exit_code} = 0 ] && [ "${action}" = "apply" ]; then
        post_apply
    fi
}

validate() {
  terraform \
    -chdir="${src_dir}" \
    validate
}

unlock() {
  terraform \
    -chdir="${src_dir}" \
    force-unlock \
    "${lock_id}"
}

post_apply() {
    if [ "${deployment}+${tf_root}" = "account+account" ] || [ "${deployment}+${tf_root}" = "deploy+account" ]; then
        echo "Performing post-apply actions"
        "${script_dir}"/../infra/scripts/subscribe-to-aws-shield-advanced.sh
    fi
}

case "${action}" in
    apply)
        pre_apply
        plan_apply "apply"
        ;;
    init)#
        pre_init
        init
        ;;
    plan)
        pre_apply # We use pre_apply here so that a plan and application look as similar as possible
        plan_apply "plan"
        ;;

    validate)
        validate
        ;;

    unlock)
        unlock
        ;;
esac


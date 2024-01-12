#!/usr/bin/env bash

set -euo pipefail

script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
deployments_dir="$(realpath "${script_dir}/../infra/deployments/")"

action=""
deployment=""
environment=""
tf_root=""

usage() {
    cat <<EOF >&2
Usage: $0 -a apply|init|plan -d deployment -e environment [-r terraform_root]

This helper script invokes Terraform in the correct manner, given the deployment,
environment, and root. It encodes the different arguments required for different
pieces of Terraform, so that operators don't have to know and remember the exact
combination for a successful application of any given root module.
EOF
    exit 1
}

# Parse args
while getopts "a:d:e:r:" opt; do
    case "${opt}" in
        a)
            case "${OPTARG}" in
                apply|init|plan)
                    action="${OPTARG}"
                    ;;
                *)
                    echo "Action (-a) must be one of apply, init, or plan." >&2
                    exit 2
                    ;;
            esac
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

# Set source directory
src_dir="${deployments_dir}/${deployment}"

if [ -n "${tf_root}" ]; then
    src_dir="${src_dir}/${tf_root}"
fi

# Handlers
init(){
    extra_args=""

    if [ "${deployment}" == "forms" ]; then
        extra_args="${extra_args} -backend-config ${deployments_dir}/account/tfvars/backends/${environment}.tfvars"
    fi

    # shellcheck disable=SC2086
    terraform \
        -chdir="${src_dir}" \
        init \
        -reconfigure \
        ${extra_args}
}

plan_or_apply(){
    action="$1"
    extra_args=""

    if [ "${deployment}" == "forms" ]; then
        extra_args="${extra_args} -var-file ${deployments_dir}/forms/tfvars/${environment}.tfvars";
    fi

    # shellcheck disable=SC2086
    terraform \
		-chdir="${src_dir}" \
		${action} \
		${extra_args}
} 

case "${action}" in
    apply)
        plan_or_apply "apply"
        ;;
    init)
        init
        ;;
    plan)
        plan_or_apply "plan"
        ;;
esac


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
Usage: $0 -a apply|init|plan|validate -d deployment -e environment [-r terraform_root]

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
            action="${OPTARG}"
            [[ $action == "apply" || $action == "init" || $action == "plan" || $action == "validate" ]] ||  usage
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
src_dir="${deployments_dir}/${deployment}/${tf_root}"
## Consider special combinations of deployment, environment, and root
case "${deployment}+${tf_root}" in
    "account+account")
        # The `account` deployment is its own root, so doesn't need an extra directory appending
        src_dir="${deployments_dir}/${deployment}"
        ;;
    "forms+pipelines")
        echo "Installing Ruby gems for infra/deployments/forms/pipelines/pipeline-invoker"
        (
            cd infra/deployments/forms/pipelines/pipeline-invoker;
            echo "Setting bundler to install gems locally"
            bundle config set --local path 'vendor/bundle'
            bundle install
            echo "Reverting bundler to install gems globally"
            bundle config set --local system 'true'
        )
        ;;
    "forms+rds")
        if [ "${TF_VAR_apply_immediately:=false}" == true ]; then
            echo "Database changes will be applied immediately"
        else
            echo "Database changes will be applied at the next maintenance window"
            echo "To apply changes immediately, set the environment variable 'TF_VAR_apply_immediately' to 'true'"
        fi
        ;;
esac

case "${environment}+${deployment}" in
    "deploy+account")
        # The 'deploy' environment has its own 'account' root module
        echo "The 'deploy' environment has its own 'account' root module. To configure it, use the 'deploy/account' root"
        exit 2
        ;;
esac

# Handlers
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

plan_apply_validate(){
    action="$1"
    extra_args=""

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

}

case "${action}" in
    apply)
        plan_apply_validate "apply"
        ;;
    init)
        init
        ;;
    plan)
        plan_apply_validate "plan"
        ;;

    validate)
        plan_apply_validate "validate"
        ;;
esac


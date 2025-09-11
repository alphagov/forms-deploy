#!/usr/bin/env bash

##
# This script is run by invoke-terraform.sh before `terraform init` is called in this directory.
# It initialises the Ruby projects that this Terraform root depends on.
##

repo_root="${1}"

init_ruby_project(){
    DIR="${1}"
    (
        echo "Initialising Ruby project at ${DIR}"
        # shellcheck disable=SC2164
        # we're confident the directories will exist
        cd "${DIR}";

        # Use already installed Ruby if running in AWS CodeBuild
        if [ "${CODEBUILD_CI:-false}" = true ]; then
          RBENV_VERSION="$(rbenv global)"
          export RBENV_VERSION
        fi

        rbenv version || mise list -c ruby

        BUNDLE_PATH="vendor/bundle" BUNDLE_WITHOUT="development:test" bundle install
    )
}

init_ruby_project "${repo_root}/infra/deployments/forms/pipelines/pipeline-invoker"
init_ruby_project "${repo_root}/support/paused-pipeline-detector"

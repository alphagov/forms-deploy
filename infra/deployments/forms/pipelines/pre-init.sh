#!/usr/bin/env bash

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

        rbenv version

        echo "Setting bundler to install gems locally"
        bundle config set --local path 'vendor/bundle'
        echo "Excluding development and test dependency groups"
        bundle config set --local without "development" "test"
        bundle install
        echo "Reverting bundler to install gems globally"
        bundle config set --local system 'true'
        echo "Reverting bundler to install development and test dependency groups"
        bundle config unsset --local without
    )
}

init_ruby_project "${repo_root}/infra/deployments/forms/pipelines/pipeline-invoker"
init_ruby_project "${repo_root}/support/paused-pipeline-detector"
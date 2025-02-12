#!/usr/bin/env bash

set -euo pipefail

##
# This post-apply script updates an AWS CodeBuild-hosted
# GitHub Actions runner to use the CodeConnections source type.
# It is necessary to do this using theAWS CLI because, at
# the time of writing, the AWS Terraform provider is missing
# the required configuration options.
##

# This absolute path of this directory is given as the fourth argument
# so that we don't need to determine it here.
src_dir="${3}"
cd "${src_dir}" || exit

forms_admin_gha_runner_name="$(terraform output -raw forms_admin_github_actions_runner_project_name)"
codeconnection_arn="$(terraform output -raw codeconnection_arn)"

project_exists="$(aws codebuild batch-get-projects --names "${forms_admin_gha_runner_name}" | jq -r '.projects|length > 0')"

source_json="$(jq \
  -rcn \
  --arg "codeconnection_arn" "${codeconnection_arn}" \
  '{"type": "GITHUB", "location": "https://github.com/alphagov/forms-admin", "auth": {"type": "CODECONNECTIONS", "resource": $codeconnection_arn}}'
)"

if [[ "${project_exists}" == true ]];
then
  echo "forms-admin GHA runner exists. Updating it."
  aws codebuild update-project \
    --name "${forms_admin_gha_runner_name}" \
    --source "${source_json}" \
  | jq '.project.source'
else
  echo "forms-admin GHA runner CodeBuild project '${forms_admin_gha_runner_name}' does not exist. This script can't do anything."
  exit 1
fi

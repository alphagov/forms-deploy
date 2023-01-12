#!/bin/bash

if [[ "$1" == "help" ]]; then
  echo "
  Returns latest pipeline status for each pipeline

  Usage:
     Run in a authorized shell using gds-cli or aws-vault
     $0 [pipeline-name]

     pipeline-name: optional name of a pipeline, defaults to all pipelines in account.

     Example:
     aws-vault exec deploy-admin -- ${0}"
  exit 0
fi

function print_summary() {
  pipeline_name="$1"

  aws codepipeline get-pipeline-state --name "$pipeline_name"  \
    | jq '.stageStates[] |
          .stageName as $stage |
          .actionStates[] |
          "\($stage)  \(.actionName) \(.latestExecution.status) \(.latestExecution.lastStatusChange)"' -r \
    | column -t
}

function list_pipelines() {
  aws codepipeline list-pipelines | jq -r '.pipelines[].name'
}

for pipeline in ${1-$(list_pipelines)}; do
  printf "\n%s\n--------\n" "$pipeline"
  print_summary "$pipeline"
done


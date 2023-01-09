#!/bin/bash

if [[ "$1" == "help" ]]; then
  echo "
  Returns latest pipeline status for each pipeline

  Usage:
     Run in a authorized shell using gds-cli or aws-vault
     $0

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

for pipeline in $(list_pipelines); do
  printf "\n%s\n--------\n" "$pipeline"
  print_summary "$pipeline"
done


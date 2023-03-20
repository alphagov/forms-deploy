#!/bin/bash

echo 'This is defunct. Use the forms-cli instead'

if [[ "$1" == "help" ]]; then
  echo "   Usage:"
  echo "     Run in a authorized shell using gds-cli or aws-vault"
  echo "     $0"
  echo "     Example:"
  echo "     aws-vault exec dev-admin -- ${0}"
  echo ""
  exit 0
fi

function get_environment() {
  local account_id
  account_id="$( aws sts get-caller-identity \
    | jq '.Account' -r)"

  case "$account_id" in
    '498160065950')
      echo "dev"
      ;;
    '972536609845')
      echo "staging"
      ;;
    '443944947292')
      echo "production"
      ;;
    '619109835131')
      echo "user-research"
      ;;
    *)
      echo "Unknown AWS account"
      exit 1
      ;;
  esac
}

environment="$(get_environment)"

function get_services() {
  services="$(aws ecs describe-services \
    --cluster "forms-${environment}" \
    --services "forms-api" "forms-admin" "forms-runner")"

  ## Get the image which isn't included in the service details...

  task_definitions="$(jq '.services[].deployments[0].taskDefinition' -r <<< "$services" )"

  counter=0
  for task in $task_definitions; do
    image="$( aws ecs describe-task-definition --task-definition "$task" \
      | jq -r '.taskDefinition.containerDefinitions[0].image | sub("^.*:";"")' )"

    services="$(jq --arg image "$image" --arg i "$counter" \
      '.services[($i | tonumber)].image |= $image' <<< "$services")"

    (( counter += 1 ))
  done

  echo "$services"
}

echo "Retrieving details for ${environment} environment"

services="$(get_services)"

jq -r '
  [
    "Name",
    "Deployment",
    "Updated",
    "Desired",
    "Running",
    "Pending",
    "Failed",
    "Image",
    "Event"
  ],
  (.services[]
  | [
      .serviceName,
      .deployments[0].rolloutState,
      (.deployments[0].updatedAt | sub("\\..*$"; "")),
      .deployments[0].desiredCount,
      .deployments[0].runningCount,
      .deployments[0].pendingCount,
      .deployments[0].failedTasks,
      .image,
      .events[0].message
    ])
  | @tsv' <<< "$(get_services)" \
  | column -t -s $'\t'

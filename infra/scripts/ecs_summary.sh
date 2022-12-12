#!/bin/bash

environment="$1"

if [[ -z "$environment" ]] || [[ "$1" == "help" ]]; then
  echo "   Usage:"
  echo "     Run in a authorized shell using gds-cli or aws-vault"
  echo "     $0 environment"
  echo "     environment either dev staging or prod"
  echo ""
  echo "     Example:"
  echo "     aws-vault exec dev-admin -- ${0} dev"
  echo ""
  exit 0
fi

echo "Retrieving ECS details"

services="$(aws ecs describe-services \
  --cluster "forms-${environment}" \
  --services "forms-api" "forms-admin" "forms-runner")"

task_definitions="$(jq \
  '.services[].deployments[0].taskDefinition' -r \
  <<< "$services" )"

images=()

counter=0
for task in $task_definitions; do
  image="$( \
    aws ecs describe-task-definition \
      --task-definition "$task" \
    | jq '.taskDefinition.containerDefinitions[0].image' -r \
   )"

  images[$counter]="$image"
  (( counter += 1 ))
done

# Print the details

for i in "${!images[@]}"; do
  image=${images[$i]}
  service_name="$( jq ".services[$i].serviceName" -r <<< "$services")"
  status="$( jq ".services[$i].deployments[0].rolloutState" -r <<< "$services")"
  echo "${service_name} ${status} ${image#*:}"
done | column -t


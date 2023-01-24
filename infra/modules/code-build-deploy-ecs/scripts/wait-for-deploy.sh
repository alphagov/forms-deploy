#!/bin/bash

SERVICE_NAME="$1"
CLUSTER_NAME="$2"

function rollout_status {
  states="$(aws ecs describe-services \
                --service "$SERVICE_NAME" \
                --cluster "${CLUSTER_NAME}" \
           | jq '.services[].deployments[0].rolloutState' -r)"
  echo "$states"
}


status="$(rollout_status)"
attempts=0

# Wait the time it generally takes to deploy and healtcheck new containers and
# then stop old containers (note deregistration delay is currently 60 seconds).
INITIAL_DELAY="${INITIAL_DELAY:-120}"
MAX_ATTEMPTS="$(( (MAX_WAIT_TIME_SECONDS - INITIAL_DELAY) / DEPLOYMENT_UPDATE_POLLING_SECONDS ))"
echo "Waiting ${INITIAL_DELAY} seconds for deployment"
sleep "$INITIAL_DELAY"

while [[ "$status" != "COMPLETED" ]]; do
  echo "${attempts}: Current state: ${status}"

  (( attempts += 1 ))

  if [[ "$attempts" -gt "$MAX_ATTEMPTS" ]]; then
    echo "Failed to update, max wait time exceeded"
    echo "Check ECS task ${CLUSTER_NAME}:${SERVICE_NAME}"
    exit 1
  fi


  if [[ "${status}" == "FAILED" ]]; then
    echo "Failed to update, Deployment status FAILED"
    echo "Check ECS task ${CLUSTER_NAME}:${SERVICE_NAME}"
    exit 1
  fi


  echo "Waiting ${DEPLOYMENT_UPDATE_POLLING_SECONDS} seconds"
  sleep "$DEPLOYMENT_UPDATE_POLLING_SECONDS";
  status="$(rollout_status)"
done;

echo "ECS deployment is finished"


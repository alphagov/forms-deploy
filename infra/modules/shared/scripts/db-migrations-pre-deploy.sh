#!/usr/bin/env bash
set -e -u -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Generate the JSON for the request
jq -nrM -f \
    --argjson "CONTAINER_DEFINITION_JSON" "${CONTAINER_DEFINITION_JSON}" \
    --argjson "ECS_TASK_NETWORK_CONFIGURATION" "${ECS_TASK_NETWORK_CONFIGURATION}" \
    --arg "ECS_CLUSTER_ARN" "${ECS_CLUSTER_ARN}" \
    --arg "ECS_TASK_DEFINITION_ARN" "${ECS_TASK_DEFINITION_ARN}" \
    "${SCRIPT_DIR}/db-migrations-ecs-run-task-input.jq" \
    > "${SCRIPT_DIR}/run-task-input.tmp.json"

# Start the task and get the task ARN
RUNNING_TASK_ARN=$( \
     aws ecs run-task --cli-input-json "file://${SCRIPT_DIR}/run-task-input.tmp.json" \
     | jq -r '.tasks[0].taskArn' \
)

echo "Running task ARN: ${RUNNING_TASK_ARN}"

# Wait for the task to stop
echo "Waiting for the task to finish"
aws ecs wait tasks-stopped --tasks "${RUNNING_TASK_ARN}" --cluster "${ECS_CLUSTER_ARN}"

# Determine the exit code
# No failures: 0
# Any failures: 1
EXIT_CODE=$(\
    aws ecs describe-tasks --tasks "${RUNNING_TASK_ARN}" --cluster "${ECS_CLUSTER_ARN}" \
    | jq -r '.tasks[0].containers[0].exitCode'
)

exit "${EXIT_CODE}"

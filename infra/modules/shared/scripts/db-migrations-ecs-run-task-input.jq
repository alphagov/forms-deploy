{
    "cluster": $ECS_CLUSTER_ARN,
    "taskDefinition": $ECS_TASK_DEFINITION_ARN,
    "count": 1,
    "launchType": "FARGATE",
    "overrides": {
        "containerOverrides": [
            {
                "name": ($CONTAINER_DEFINITION_JSON | .name),
                "command": ["rake", "db:migrate"],
                "environment": [
                    { "name": "VERBOSE", "value": "true" }
                ]
            }
        ]
    },
    "networkConfiguration": {
        "awsvpcConfiguration": {
            "subnets": ($ECS_TASK_NETWORK_CONFIGURATION | .subnets),
            "securityGroups": ($ECS_TASK_NETWORK_CONFIGURATION | .securityGroups),
            "assignPublicIp": (if ($ECS_TASK_NETWORK_CONFIGURATION|.assignPublicIp) then "ENABLED" else "DISABLED" end)
        }
    }
}

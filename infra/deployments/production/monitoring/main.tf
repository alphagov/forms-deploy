resource "aws_cloudwatch_dashboard" "overview" {
  dashboard_name = "Overview"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "height": 5,
            "width": 24,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "targetgroup/forms-runner-production/dc1ef6b38be73050", "LoadBalancer", "app/forms-production/ca3f9a7d949e0ddd", { "label": "forms-runner-production" } ],
                    [ "...", "targetgroup/forms-api-production/c0855c3550515fa1", ".", ".", { "label": "forms-api-production" } ],
                    [ "...", "targetgroup/forms-admin-production/3f3c0ec1ec914bdb", ".", ".", { "label": "forms-admin-production" } ]
                ],
                "sparkline": true,
                "view": "timeSeries",
                "region": "eu-west-2",
                "stacked": false,
                "stat": "Minimum",
                "period": 60,
                "title": "Healthy Host Count Per Target Group"
            }
        },
        {
            "height": 5,
            "width": 24,
            "y": 5,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "RunningTaskCount", "ServiceName", "forms-api", "ClusterName", "forms-production", { "stat": "Minimum", "color": "#2ca02c" } ],
                    [ ".", "PendingTaskCount", ".", ".", ".", "." ],
                    [ ".", "DesiredTaskCount", ".", ".", ".", ".", { "color": "#1f77b4" } ],
                    [ ".", "DeploymentCount", ".", ".", ".", ".", { "color": "#9467bd" } ]
                ],
                "sparkline": true,
                "view": "singleValue",
                "region": "eu-west-2",
                "stat": "Maximum",
                "period": 1,
                "title": "Forms API ECS Summary"
            }
        },
        {
            "height": 5,
            "width": 24,
            "y": 10,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "RunningTaskCount", "ServiceName", "forms-admin", "ClusterName", "forms-production", { "stat": "Minimum", "color": "#2ca02c" } ],
                    [ ".", "PendingTaskCount", ".", ".", ".", "." ],
                    [ ".", "DesiredTaskCount", ".", ".", ".", ".", { "color": "#1f77b4" } ],
                    [ ".", "DeploymentCount", ".", ".", ".", ".", { "color": "#9467bd" } ]
                ],
                "sparkline": true,
                "view": "singleValue",
                "region": "eu-west-2",
                "stat": "Maximum",
                "period": 1,
                "title": "Forms Admin ECS Summary"
            }
        },
        {
            "height": 5,
            "width": 24,
            "y": 15,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "RunningTaskCount", "ServiceName", "forms-runner", "ClusterName", "forms-production", { "stat": "Minimum", "color": "#2ca02c" } ],
                    [ ".", "PendingTaskCount", ".", ".", ".", "." ],
                    [ ".", "DesiredTaskCount", ".", ".", ".", ".", { "color": "#1f77b4" } ],
                    [ ".", "DeploymentCount", ".", ".", ".", ".", { "color": "#9467bd" } ]
                ],
                "sparkline": true,
                "view": "singleValue",
                "region": "eu-west-2",
                "stat": "Maximum",
                "period": 1,
                "title": "Forms Runner ECS Summary"
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 20,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "TargetGroup", "targetgroup/forms-admin-production/3f3c0ec1ec914bdb", "LoadBalancer", "app/forms-production/ca3f9a7d949e0ddd", { "color": "#d62728" } ],
                    [ ".", "RequestCount", ".", ".", ".", ".", { "color": "#1f77b4" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "stat": "Sum",
                "period": 60,
                "title": "Forms-Admin Requests"
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 20,
            "x": 8,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "TargetGroup", "targetgroup/forms-runner-production/dc1ef6b38be73050", "LoadBalancer", "app/forms-production/ca3f9a7d949e0ddd", { "color": "#d62728" } ],
                    [ ".", "RequestCount", ".", ".", ".", ".", { "color": "#1f77b4" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "stat": "Sum",
                "period": 60,
                "title": "Forms-Runner Requests"
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 20,
            "x": 16,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "TargetGroup", "targetgroup/forms-api-production/c0855c3550515fa1", "LoadBalancer", "app/forms-production/ca3f9a7d949e0ddd", { "color": "#d62728" } ],
                    [ ".", "RequestCount", ".", ".", ".", ".", { "color": "#1f77b4" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "stat": "Sum",
                "period": 60,
                "title": "Forms-Api Requests"
            }
        }
    ]
}
EOF
}


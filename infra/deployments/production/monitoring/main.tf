resource "aws_cloudwatch_dashboard" "overview" {
  dashboard_name = "Overview"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "height": 6,
            "width": 8,
            "y": 3,
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
            "y": 3,
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
            "y": 3,
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
        },
        {
            "height": 6,
            "width": 8,
            "y": 9,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "CpuReserved", "ServiceName", "forms-runner", "ClusterName", "forms-production", { "region": "eu-west-2" } ],
                    [ ".", "CpuUtilized", ".", "forms-admin", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-api", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-product-page", ".", ".", { "region": "eu-west-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "period": 300,
                "stat": "Average",
                "title": "ECS CPU Utilisation"
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 9,
            "x": 8,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "MemoryReserved", "ServiceName", "forms-admin", "ClusterName", "forms-production", { "region": "eu-west-2" } ],
                    [ ".", "MemoryUtilized", ".", ".", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-api", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-product-page", ".", ".", { "region": "eu-west-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ECS Memory Utilisation",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "height": 3,
            "width": 24,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "targetgroup/forms-admin-production/3f3c0ec1ec914bdb", "LoadBalancer", "app/forms-production/ca3f9a7d949e0ddd", { "region": "eu-west-2" } ],
                    [ "...", "targetgroup/forms-api-production/c0855c3550515fa1", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "targetgroup/forms-runner-production/dc1ef6b38be73050", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "targetgroup/forms-product-page-production/eea72df3bd4e7081", ".", ".", { "region": "eu-west-2" } ]
                ],
                "sparkline": true,
                "view": "singleValue",
                "region": "eu-west-2",
                "period": 300,
                "stat": "Average",
                "title": "ALB Healthy Host Count"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 15,
            "x": 16,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/RDS", "CPUUtilization", { "period": 60 } ]
                ],
                "region": "eu-west-2",
                "title": "RDS CPU Utilization"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 15,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "ReadIOPS", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "ReadLatency", { "region": "eu-west-2" } ],
                    [ ".", "ReadThroughput", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "WriteIOPS", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "WriteLatency", { "region": "eu-west-2" } ],
                    [ ".", "WriteThroughput", { "region": "eu-west-2", "visible": false } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "RDS Read/Write Latency",
                "period": 60,
                "stat": "Average"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 15,
            "x": 8,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "ReadIOPS", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "ReadLatency", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "ReadThroughput", { "region": "eu-west-2" } ],
                    [ ".", "WriteIOPS", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "WriteLatency", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "WriteThroughput", { "region": "eu-west-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "RDS Read/Write Throughput",
                "period": 60,
                "stat": "Average"
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 9,
            "x": 16,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "DesiredTaskCount", "ServiceName", "forms-admin", "ClusterName", "forms-production", { "region": "eu-west-2" } ],
                    [ ".", "RunningTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "PendingTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "RunningTaskCount", ".", "forms-api", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "PendingTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "RunningTaskCount", ".", "forms-runner", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "PendingTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "RunningTaskCount", ".", "forms-product-page", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "PendingTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "period": 300,
                "stat": "Average",
                "title": "ECS Pending/Running Task Count"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 22,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ElastiCache", "CPUUtilization", { "region": "eu-west-2" } ],
                    [ ".", ".", "CacheClusterId", "forms-runner-production-001" ],
                    [ "...", "forms-runner-production-002" ],
                    [ "...", "forms-runner-production-003" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "period": 300,
                "title": "Redis CPU Utilization",
                "stat": "Average"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 22,
            "x": 8,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ElastiCache", "SwapUsage", { "region": "eu-west-2" } ],
                    [ ".", ".", "CacheClusterId", "forms-runner-production-001", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner-production-002", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner-production-003", { "region": "eu-west-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "Redis Swap Usage",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 22,
            "x": 16,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ElastiCache", "FreeableMemory", { "region": "eu-west-2" } ],
                    [ ".", ".", "CacheClusterId", "forms-runner-production-001", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner-production-002", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner-production-003", { "region": "eu-west-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "Redis Freeable Memory",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 29,
            "x": 0,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ElastiCache", "CacheHitRate" ],
                    [ ".", "CacheHits" ],
                    [ ".", "CacheMisses" ]
                ],
                "region": "eu-west-2",
                "title": "Redis Cache HitRate, Cache Hits, Cache Misses"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 29,
            "x": 8,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ElastiCache", "DatabaseMemoryUsagePercentage", { "region": "eu-west-2" } ],
                    [ ".", ".", "CacheClusterId", "forms-runner-production-001", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner-production-002", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner-production-003" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "Redis Database Memory Usage Percentage",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 29,
            "x": 16,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ElastiCache", "CurrConnections", { "region": "eu-west-2" } ],
                    [ ".", "NewConnections", { "region": "eu-west-2" } ],
                    [ ".", "CurrConnections", "CacheClusterId", "forms-runner-production-001", { "region": "eu-west-2" } ],
                    [ ".", "NewConnections", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "CurrConnections", ".", "forms-runner-production-002", { "region": "eu-west-2" } ],
                    [ ".", "NewConnections", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "CurrConnections", ".", "forms-runner-production-003", { "region": "eu-west-2" } ],
                    [ ".", "NewConnections", ".", ".", { "region": "eu-west-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "Redis Current/ New Connections",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 36,
            "x": 0,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ElastiCache", "Evictions" ],
                    [ ".", ".", "CacheClusterId", "forms-runner-production-001" ],
                    [ "...", "forms-runner-production-002" ],
                    [ "...", "forms-runner-production-003" ]
                ],
                "region": "eu-west-2",
                "title": "Redis Evictions"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 43,
            "x": 8,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "ActiveConnectionCount", "LoadBalancer", "app/forms-production/ca3f9a7d949e0ddd", "AvailabilityZone", "eu-west-2a", { "region": "eu-west-2" } ],
                    [ "...", "eu-west-2b", { "region": "eu-west-2" } ],
                    [ "...", "eu-west-2c", { "region": "eu-west-2" } ],
                    [ ".", "NewConnectionCount", ".", ".", ".", "eu-west-2a", { "region": "eu-west-2" } ],
                    [ "...", "eu-west-2b", { "region": "eu-west-2" } ],
                    [ "...", "eu-west-2c", { "region": "eu-west-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ALB Connection Count",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 43,
            "x": 16,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "ProcessedBytes", "LoadBalancer", "app/forms-production/ca3f9a7d949e0ddd", { "region": "eu-west-2" } ],
                    [ ".", "ActiveConnectionCount", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "NewConnectionCount", ".", "." ]
                ],
                "region": "eu-west-2",
                "period": 300,
                "title": "ALB Traffic Metrics"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 50,
            "x": 0,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", "targetgroup/forms-admin-production/3f3c0ec1ec914bdb", "LoadBalancer", "app/forms-production/ca3f9a7d949e0ddd" ],
                    [ "...", "targetgroup/forms-api-production/c0855c3550515fa1", ".", "." ],
                    [ "...", "targetgroup/forms-runner-production/dc1ef6b38be73050", ".", "." ],
                    [ "...", "targetgroup/forms-product-page-production/eea72df3bd4e7081", ".", "." ],
                    [ ".", ".", "LoadBalancer", "app/forms-production/ca3f9a7d949e0ddd" ]
                ],
                "region": "eu-west-2",
                "title": "ALB Latency Metrics (Target Response Time)"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 43,
            "x": 0,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", "app/forms-production/ca3f9a7d949e0ddd", "AvailabilityZone", "eu-west-2b" ],
                    [ "...", "eu-west-2c" ],
                    [ "...", "eu-west-2a" ],
                    [ ".", ".", ".", "." ]
                ],
                "region": "eu-west-2",
                "title": "ALB Error Metrics (HTTPCode_ELB_4XX/5XX_Count)"
            }
        },
        {
            "height": 7,
            "width": 8,
            "y": 36,
            "x": 16,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCountPerTarget", "TargetGroup", "targetgroup/forms-admin-production/3f3c0ec1ec914bdb", { "region": "eu-west-2" } ],
                    [ "...", "targetgroup/forms-api-production/c0855c3550515fa1", { "region": "eu-west-2" } ],
                    [ "...", "targetgroup/forms-runner-production/dc1ef6b38be73050", { "region": "eu-west-2" } ],
                    [ "...", "targetgroup/forms-product-page-production/eea72df3bd4e7081", { "region": "eu-west-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ALB Http reqest ( RequestCountPerTarget) ",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 8,
            "y": 36,
            "width": 8,
            "height": 7,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ElastiCache", "CurrItems" ],
                    [ ".", ".", "CacheClusterId", "forms-runner-production-001" ],
                    [ "...", "forms-runner-production-002" ],
                    [ "...", "forms-runner-production-003" ]
                ],
                "region": "eu-west-2",
                "title": "Redis Item Count"
            }
        }
    ]
}
EOF
}


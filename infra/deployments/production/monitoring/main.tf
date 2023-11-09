resource "aws_cloudwatch_dashboard" "overview" {
  dashboard_name = "Overview"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "height": 5,
            "width": 12,
            "y": 14,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "expression": "100*(m1/m7)", "id": "e1", "label": "forms-runner", "region": "eu-west-2" } ],
                    [ { "expression": "100*(m2/m6)", "id": "e2", "label": "forms-api", "region": "eu-west-2" } ],
                    [ { "expression": "100*(m4/m5)", "id": "e3", "label": "forms-admin", "region": "eu-west-2" } ],
                    [ { "expression": "100*(m3/m8)", "id": "e4", "label": "forms-product-page", "region": "eu-west-2" } ],
                    [ "ECS/ContainerInsights", "CpuUtilized", "ServiceName", "forms-runner", "ClusterName", "forms-dev", { "region": "eu-west-2", "id": "m1", "visible": false } ],
                    [ "...", "forms-api", ".", ".", { "region": "eu-west-2", "id": "m2", "visible": false } ],
                    [ "...", "forms-product-page", ".", ".", { "region": "eu-west-2", "id": "m3", "visible": false } ],
                    [ "...", "forms-admin", ".", ".", { "region": "eu-west-2", "id": "m4", "visible": false } ],
                    [ ".", "CpuReserved", ".", "forms-runner", ".", ".", { "region": "eu-west-2", "id": "m7", "yAxis": "right", "label": "forms-runner CpuReserved [last: $${LAST}]" } ],
                    [ "...", "forms-api", ".", ".", { "region": "eu-west-2", "id": "m6", "yAxis": "right", "label": "forms-api CpuReserved [last: $${LAST}]" } ],
                    [ "...", "forms-admin", ".", ".", { "region": "eu-west-2", "id": "m5", "yAxis": "right", "label": "forms-admin CpuReserved [last: $${LAST}]" } ],
                    [ "...", "forms-product-page", ".", ".", { "id": "m8", "label": "forms-product-page CpuReserved [last: $${LAST}]", "yAxis": "right", "region": "eu-west-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "stat": "Maximum",
                "period": 5,
                "title": "ECS CPU Utilization (Percent)",
                "liveData": true,
                "yAxis": {
                    "left": {
                        "showUnits": false,
                        "label": "Percent"
                    },
                    "right": {
                        "showUnits": true,
                        "label": ""
                    }
                }
            }
        },
        {
            "height": 5,
            "width": 12,
            "y": 14,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "expression": "100*(m1/m2)", "label": "forms-runner", "id": "e1", "region": "eu-west-2" } ],
                    [ { "expression": "100*(m3/m6)", "label": "forms-api", "id": "e2", "region": "eu-west-2" } ],
                    [ { "expression": "100*(m5/m7)", "label": "forms-admin", "id": "e4", "region": "eu-west-2" } ],
                    [ { "expression": "100*(m4/m8)", "label": "forms-product-page", "id": "e3", "region": "eu-west-2" } ],
                    [ "ECS/ContainerInsights", "MemoryUtilized", "ServiceName", "forms-runner", "ClusterName", "forms-dev", { "region": "eu-west-2", "id": "m1", "visible": false } ],
                    [ ".", "MemoryReserved", ".", ".", ".", ".", { "region": "eu-west-2", "id": "m2", "label": "forms-runner MemoryReserved [last: $${LAST}]", "yAxis": "right" } ],
                    [ ".", "MemoryUtilized", ".", "forms-api", ".", ".", { "region": "eu-west-2", "id": "m3", "visible": false } ],
                    [ ".", "MemoryReserved", ".", ".", ".", ".", { "id": "m6", "region": "eu-west-2", "label": "forms-api MemoryReserved [last: $${LAST}]", "yAxis": "right" } ],
                    [ ".", "MemoryUtilized", ".", "forms-product-page", ".", ".", { "region": "eu-west-2", "id": "m4", "visible": false } ],
                    [ ".", "MemoryReserved", ".", ".", ".", ".", { "id": "m8", "region": "eu-west-2", "label": "forms-product-page MemoryReserved [last: $${LAST}]", "yAxis": "right" } ],
                    [ ".", "MemoryUtilized", ".", "forms-admin", ".", ".", { "region": "eu-west-2", "id": "m5", "visible": false } ],
                    [ ".", "MemoryReserved", ".", ".", ".", ".", { "id": "m7", "region": "eu-west-2", "yAxis": "right", "label": "forms-admin MemoryReserved [last: $${LAST}]" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "stat": "Maximum",
                "period": 5,
                "title": "ECS Memory Utilization (Percent)",
                "yAxis": {
                    "left": {
                        "label": "Percent",
                        "showUnits": false
                    }
                }
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 25,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "CPUUtilization", "DBClusterIdentifier", "aurora-cluster-dev", { "region": "eu-west-2", "visible": false } ],
                    [ "AWS/ElastiCache", ".", "CacheClusterId", "forms-runner-dev-002", "CacheNodeId", "0001", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-runner-dev-003", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-runner-dev-001", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", ".", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner-dev-002", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner-dev-003", { "region": "eu-west-2" } ],
                    [ ".", "." ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "stat": "Maximum",
                "period": 5,
                "title": "Redis Maximum CPU Utilization per 5 seconds"
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 43,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", "targetgroup/forms-runner-dev/1afc802c389b5ecd", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", { "region": "eu-west-2", "color": "#d62728" } ],
                    [ "...", { "region": "eu-west-2", "stat": "p99", "color": "#2ca02c" } ],
                    [ "...", { "region": "eu-west-2", "stat": "Average", "color": "#1f77b4" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ALB Forms-runner Latency (Target Response Time)",
                "stat": "Maximum",
                "period": 60,
                "liveData": true
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
                    [ "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "targetgroup/forms-api-dev/53e75a980b6d83b8", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", { "region": "eu-west-2" } ],
                    [ "...", "targetgroup/forms-runner-dev/1afc802c389b5ecd", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "targetgroup/forms-admin-dev/07b0e446fe4671b1", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "targetgroup/forms-product-page-dev/869490357a5954a9", ".", ".", { "region": "eu-west-2" } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ALB HealthyHostCount",
                "period": 300,
                "stat": "Maximum",
                "sparkline": true,
                "setPeriodToTimeRange": false,
                "trend": true
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 19,
            "x": 0,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/RDS", "CPUUtilization", "EngineName", "aurora-postgresql", { "period": 60 } ]
                ],
                "region": "eu-west-2",
                "title": "RDS CPU Utilization"
            }
        },
        {
            "height": 5,
            "width": 24,
            "y": 9,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", { "region": "eu-west-2" } ],
                    [ "AWS/ApplicationELB", "RequestCount", "TargetGroup", "targetgroup/forms-runner-dev/1afc802c389b5ecd", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", { "region": "eu-west-2" } ],
                    [ "AWS/ApplicationELB", "RequestCount", "TargetGroup", "targetgroup/forms-api-dev/53e75a980b6d83b8", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", { "region": "eu-west-2" } ],
                    [ "AWS/ApplicationELB", "RequestCount", "TargetGroup", "targetgroup/forms-product-page-dev/869490357a5954a9", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", { "region": "eu-west-2" } ],
                    [ "AWS/ApplicationELB", "RequestCount", "TargetGroup", "targetgroup/forms-admin-dev/07b0e446fe4671b1", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", { "region": "eu-west-2" } ],
                    [ "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "TargetGroup", "targetgroup/forms-runner-dev/1afc802c389b5ecd", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", "AvailabilityZone", "eu-west-2b", { "region": "eu-west-2", "visible": false } ],
                    [ "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "TargetGroup", "targetgroup/forms-admin-dev/07b0e446fe4671b1", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", "AvailabilityZone", "eu-west-2b", { "region": "eu-west-2", "visible": false } ],
                    [ "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "TargetGroup", "targetgroup/forms-admin-dev/07b0e446fe4671b1", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", "AvailabilityZone", "eu-west-2c", { "region": "eu-west-2", "visible": false } ],
                    [ "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "TargetGroup", "targetgroup/forms-admin-dev/07b0e446fe4671b1", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", "AvailabilityZone", "eu-west-2a", { "region": "eu-west-2", "visible": false } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "period": 60,
                "stat": "Sum",
                "title": "ALB RequestCount"
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 19,
            "x": 16,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "WriteLatency", { "region": "eu-west-2" } ],
                    [ ".", "ReadLatency", { "region": "eu-west-2" } ]
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
            "height": 6,
            "width": 8,
            "y": 19,
            "x": 8,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "ReadThroughput", { "region": "eu-west-2" } ],
                    [ ".", "WriteThroughput", { "region": "eu-west-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "RDS Read/Write Throughtput",
                "period": 60,
                "stat": "Average"
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 31,
            "x": 8,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ElastiCache", "SwapUsage", { "region": "eu-west-2" } ]
                ],
                "view": "gauge",
                "stacked": false,
                "region": "eu-west-2",
                "title": "Redis Swap Usage",
                "period": 300,
                "stat": "Average",
                "yAxis": {
                    "left": {
                        "min": 0,
                        "max": 500000000
                    }
                },
                "annotations": {
                    "horizontal": [
                        {
                            "color": "#d62728",
                            "label": "broken things (https://repost.aws/knowledge-center/elasticache-swap-activity)",
                            "value": 300000000,
                            "fill": "above"
                        },
                        {
                            "color": "#2ca02c",
                            "label": "Untitled annotation",
                            "value": 300000000,
                            "fill": "below"
                        }
                    ]
                }
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 43,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", { "region": "eu-west-2", "visible": false } ],
                    [ ".", ".", "TargetGroup", "targetgroup/forms-admin-dev/07b0e446fe4671b1", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", { "region": "eu-west-2" } ],
                    [ "...", { "region": "eu-west-2", "stat": "p99" } ],
                    [ "...", { "region": "eu-west-2", "stat": "Maximum" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ALB Forms-admin Latency metrics (Target Response Time)",
                "period": 60,
                "stat": "Average"
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 43,
            "x": 6,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", { "region": "eu-west-2", "visible": false } ],
                    [ ".", ".", "TargetGroup", "targetgroup/forms-api-dev/53e75a980b6d83b8", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", { "region": "eu-west-2" } ],
                    [ "...", { "region": "eu-west-2", "stat": "p99" } ],
                    [ "...", { "region": "eu-west-2", "stat": "Maximum" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ALB Forms-api Latency metrics (Target Response Time)",
                "period": 60,
                "stat": "Average"
            }
        },
        {
            "height": 6,
            "width": 12,
            "y": 37,
            "x": 12,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "ProcessedBytes", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", { "region": "eu-west-2" } ]
                ],
                "region": "eu-west-2",
                "title": "ALB Traffic metrics (ProcessedBytes)",
                "period": 300
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 31,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ElastiCache", "CacheHitRate", { "region": "eu-west-2", "yAxis": "left" } ],
                    [ ".", "CacheHits", { "region": "eu-west-2", "yAxis": "right" } ],
                    [ ".", "CacheMisses", { "region": "eu-west-2", "yAxis": "right" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "Redis CacheHitRate, CacheHits, CacheMisses",
                "period": 60,
                "stat": "Maximum",
                "yAxis": {
                    "left": {
                        "label": "Cache Hit Ratio",
                        "min": 0,
                        "max": 100
                    },
                    "right": {
                        "label": "Hits and Misses"
                    }
                }
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 25,
            "x": 8,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ElastiCache", "DatabaseMemoryUsagePercentage" ],
                    [ ".", ".", "CacheClusterId", "forms-runner-dev-001" ],
                    [ "...", "forms-runner-dev-002" ],
                    [ "...", "forms-runner-dev-003" ]
                ],
                "region": "eu-west-2",
                "title": "Redis Database Memory Usage Percentage"
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 31,
            "x": 16,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ElastiCache", "CurrItems", { "region": "eu-west-2" } ],
                    [ ".", "Evictions", { "region": "eu-west-2" } ],
                    [ ".", "CurrItems", "CacheClusterId", "forms-runner-dev-001", { "region": "eu-west-2" } ],
                    [ ".", ".", ".", ".", "CacheNodeId", "0001", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner-dev-002", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner-dev-003", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "Evictions", ".", "forms-runner-dev-001", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner-dev-002", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner-dev-003", { "region": "eu-west-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "stat": "Maximum",
                "period": 5,
                "title": "Redis CurrItems and Evictions"
            }
        },
        {
            "height": 6,
            "width": 12,
            "y": 37,
            "x": 0,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "NewConnectionCount", "LoadBalancer", "app/forms-dev/f3826dd90cb25783" ],
                    [ ".", "ActiveConnectionCount", ".", "." ]
                ],
                "region": "eu-west-2",
                "title": "ALB Active/New Connection Count"
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 25,
            "x": 16,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ElastiCache", "CurrConnections", { "region": "eu-west-2" } ],
                    [ ".", "NewConnections", { "region": "eu-west-2" } ],
                    [ ".", "CurrConnections", "CacheClusterId", "forms-runner-dev-001", "CacheNodeId", "0001", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner-dev-002", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner-dev-003", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "NewConnections", ".", "forms-runner-dev-001" ],
                    [ "...", "forms-runner-dev-002" ],
                    [ "...", "forms-runner-dev-003" ]
                ],
                "region": "eu-west-2",
                "title": "Redis Current/NewConnections",
                "period": 300
            }
        },
        {
            "height": 3,
            "width": 12,
            "y": 3,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "RunningTaskCount", "ServiceName", "forms-api", "ClusterName", "forms-dev", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-runner", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "PendingTaskCount", ".", "forms-product-page", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "RunningTaskCount", ".", ".", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "PendingTaskCount", ".", "forms-admin", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "RunningTaskCount", ".", ".", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "PendingTaskCount", ".", "forms-runner", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-api", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "DesiredTaskCount", ".", "forms-runner", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-admin", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-api", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-product-page", ".", ".", { "region": "eu-west-2", "visible": false } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ECS Pending/Running Task Count - Forms Runner",
                "period": 300,
                "stat": "Maximum",
                "yAxis": {
                    "left": {
                        "min": 0,
                        "max": 3
                    }
                },
                "annotations": {
                    "horizontal": [
                        {
                            "visible": false,
                            "color": "#b2df8d",
                            "label": "Untitled annotation",
                            "value": 3.1,
                            "fill": "below"
                        },
                        {
                            "visible": false,
                            "color": "#d62728",
                            "label": "Untitled annotation",
                            "value": 3.1,
                            "fill": "above"
                        },
                        {
                            "visible": false,
                            "color": "#ff7f0e",
                            "label": "Untitled annotation",
                            "value": 0,
                            "fill": "above"
                        }
                    ]
                },
                "setPeriodToTimeRange": false,
                "legend": {
                    "position": "bottom"
                },
                "sparkline": true,
                "trend": true
            }
        },
        {
            "height": 3,
            "width": 12,
            "y": 3,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "RunningTaskCount", "ServiceName", "forms-api", "ClusterName", "forms-dev", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "PendingTaskCount", ".", "forms-product-page", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "RunningTaskCount", ".", ".", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "PendingTaskCount", ".", "forms-admin", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "RunningTaskCount", ".", ".", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "PendingTaskCount", ".", "forms-runner", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-api", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "DesiredTaskCount", ".", "forms-runner", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-admin", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-api", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-product-page", ".", ".", { "region": "eu-west-2", "visible": false } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ECS Pending/Running Task Count - Forms API",
                "period": 300,
                "stat": "Maximum",
                "yAxis": {
                    "left": {
                        "min": 0,
                        "max": 3
                    }
                },
                "annotations": {
                    "horizontal": [
                        {
                            "visible": false,
                            "color": "#b2df8d",
                            "label": "Untitled annotation",
                            "value": 3.1,
                            "fill": "below"
                        },
                        {
                            "visible": false,
                            "color": "#d62728",
                            "label": "Untitled annotation",
                            "value": 3.1,
                            "fill": "above"
                        },
                        {
                            "visible": false,
                            "color": "#ff7f0e",
                            "label": "Untitled annotation",
                            "value": 0,
                            "fill": "above"
                        }
                    ]
                },
                "setPeriodToTimeRange": false,
                "legend": {
                    "position": "bottom"
                },
                "sparkline": true,
                "trend": true
            }
        },
        {
            "height": 3,
            "width": 12,
            "y": 6,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "RunningTaskCount", "ServiceName", "forms-api", "ClusterName", "forms-dev", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-runner", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-product-page", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "PendingTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-admin", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "RunningTaskCount", ".", ".", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "PendingTaskCount", ".", "forms-runner", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-api", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "DesiredTaskCount", ".", "forms-runner", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-admin", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-api", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-product-page", ".", ".", { "region": "eu-west-2" } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ECS Pending/Running Task Count - Forms Product Page",
                "period": 300,
                "stat": "Maximum",
                "yAxis": {
                    "left": {
                        "min": 0,
                        "max": 3
                    }
                },
                "annotations": {
                    "horizontal": [
                        {
                            "visible": false,
                            "color": "#b2df8d",
                            "label": "Untitled annotation",
                            "value": 3.1,
                            "fill": "below"
                        },
                        {
                            "visible": false,
                            "color": "#d62728",
                            "label": "Untitled annotation",
                            "value": 3.1,
                            "fill": "above"
                        },
                        {
                            "visible": false,
                            "color": "#ff7f0e",
                            "label": "Untitled annotation",
                            "value": 0,
                            "fill": "above"
                        }
                    ]
                },
                "setPeriodToTimeRange": false,
                "legend": {
                    "position": "bottom"
                },
                "sparkline": true,
                "trend": true
            }
        },
        {
            "height": 3,
            "width": 12,
            "y": 6,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "RunningTaskCount", "ServiceName", "forms-api", "ClusterName", "forms-dev", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-runner", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-product-page", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "PendingTaskCount", ".", ".", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "RunningTaskCount", ".", "forms-admin", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "PendingTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-runner", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-api", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ ".", "DesiredTaskCount", ".", "forms-runner", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-admin", ".", ".", { "region": "eu-west-2" } ],
                    [ "...", "forms-api", ".", ".", { "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-product-page", ".", ".", { "region": "eu-west-2", "visible": false } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ECS Pending/Running Task Count - Forms admin",
                "period": 300,
                "stat": "Maximum",
                "yAxis": {
                    "left": {
                        "min": 0,
                        "max": 3
                    }
                },
                "annotations": {
                    "horizontal": [
                        {
                            "visible": false,
                            "color": "#b2df8d",
                            "label": "Untitled annotation",
                            "value": 3.1,
                            "fill": "below"
                        },
                        {
                            "visible": false,
                            "color": "#d62728",
                            "label": "Untitled annotation",
                            "value": 3.1,
                            "fill": "above"
                        },
                        {
                            "visible": false,
                            "color": "#ff7f0e",
                            "label": "Untitled annotation",
                            "value": 0,
                            "fill": "above"
                        }
                    ]
                },
                "setPeriodToTimeRange": false,
                "legend": {
                    "position": "bottom"
                },
                "sparkline": true,
                "trend": true
            }
        },
        {
            "height": 9,
            "width": 24,
            "y": 49,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/SES", "Delivery" ],
                    [ ".", "Send" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "title": "SES Send and Deliver (Sample Count 1 minute)",
                "region": "eu-west-2",
                "stat": "SampleCount",
                "period": 60
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 43,
            "x": 18,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", "targetgroup/forms-product-page-dev/869490357a5954a9", "LoadBalancer", "app/forms-dev/f3826dd90cb25783", { "region": "eu-west-2" } ],
                    [ "...", { "region": "eu-west-2", "stat": "p99" } ],
                    [ "...", { "region": "eu-west-2", "stat": "Average" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ALB Forms-Product-page Latency (Target Response Time)",
                "stat": "Maximum",
                "period": 60,
                "liveData": true
            }
        }
    ]
}
EOF
}


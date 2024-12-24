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
                    [ { "expression": "100*(m1/m5)", "id": "e3", "label": "forms-admin", "region": "eu-west-2" } ],
                    [ { "expression": "100*(m2/m6)", "id": "e2", "label": "forms-api", "region": "eu-west-2" } ],
                    [ { "expression": "100*(m3/m7)", "id": "e1", "label": "forms-runner", "region": "eu-west-2" } ],
                    [ { "expression": "100*(m4/m8)", "id": "e4", "label": "forms-product-page", "region": "eu-west-2" } ],
                    [ "ECS/ContainerInsights", "CpuUtilized", "TaskDefinitionFamily", "${environment_name}_forms-admin", "ClusterName", "forms-${environment_name}", { "id": "m1", "region": "eu-west-2", "visible": false } ],
                    [ "...", "${environment_name}_forms-api", ".", ".", { "id": "m2", "region": "eu-west-2", "visible": false } ],
                    [ "...", "${environment_name}_forms-runner", ".", ".", { "id": "m3", "region": "eu-west-2", "visible": false } ],
                    [ "...", "${environment_name}_forms-product-page", ".", ".", { "id": "m4", "region": "eu-west-2", "visible": false } ],
                    [ ".", "CpuReserved", ".", "forms-admin", ".", ".", { "id": "m5", "region": "eu-west-2", "visible": false } ],
                    [ "...", "${environment_name}_forms-api", ".", ".", { "id": "m6", "region": "eu-west-2", "visible": false } ],
                    [ "...", "${environment_name}_forms-runner", ".", ".", { "id": "m7", "region": "eu-west-2", "visible": false } ],
                    [ "...", "${environment_name}_forms-product-page", ".", ".", { "id": "m8", "region": "eu-west-2", "visible": false } ]
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
                    [ { "expression": "100*(m1/m5)", "label": "forms-admin", "id": "e1", "region": "eu-west-2" } ],
                    [ { "expression": "100*(m2/m6)", "label": "forms-api", "id": "e2", "region": "eu-west-2" } ],
                    [ { "expression": "100*(m3/m7)", "label": "forms-runner", "id": "e3", "region": "eu-west-2" } ],
                    [ { "expression": "100*(m4/m8)", "label": "forms-product-page", "id": "e4", "region": "eu-west-2" } ],
                    [ "ECS/ContainerInsights", "MemoryUtilized", "ServiceName", "forms-admin", "ClusterName", "forms-${environment_name}", { "id": "m1", "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-api", ".", ".", { "id": "m2", "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-runner", ".", ".", { "id": "m3", "region": "eu-west-2", "visible": false } ],
                    [ "...", "forms-product-page", ".", ".", { "id": "m4", "region": "eu-west-2", "visible": false } ],
                    [ ".", "MemoryReserved", ".", "forms-admin", ".", ".", { "id": "m5", "region": "eu-west-2", "label": "forms-admin MemoryReserved [last: ${LAST}]", "yAxis": "right" } ],
                    [ "...", "forms-api", ".", ".", { "id": "m6", "region": "eu-west-2", "label": "forms-api MemoryReserved [last: ${LAST}]", "yAxis": "right" } ],
                    [ "...", "forms-runner", ".", ".", { "id": "m7", "region": "eu-west-2", "label": "forms-runner MemoryReserved [last: ${LAST}]", "yAxis": "right" } ],
                    [ "...", "forms-product-page", ".", ".", { "id": "m8", "region": "eu-west-2", "label": "forms-product-page MemoryReserved [last: ${LAST}]", "yAxis": "right" } ]
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
                    [ "AWS/ElastiCache", "CPUUtilization", { "region": "eu-west-2", "yAxis": "left" } ],
                    [ { "expression": "SEARCH('{AWS/ElastiCache, CacheClusterId} MetricName=\"CPUUtilization\" forms-runner', 'Maximum')", "label": "", "id": "e1" } ]
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
            "height": 3,
            "width": 24,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer, TargetGroup} MetricName=\"HealthyHostCount\"', 'Maximum')", "label": "", "id": "e1" } ]
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
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer, TargetGroup} MetricName=\"RequestCount\"', 'Sum')", "label": "", "id": "e1" } ],
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer} MetricName=\"RequestCount\"', 'Sum')", "label": "", "id": "e2" } ]
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
            "y": 42,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer, TargetGroup} MetricName=\"TargetResponseTime\" forms-admin', 'Average')", "label": "Average", "id": "e1" } ],
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer, TargetGroup} MetricName=\"TargetResponseTime\" forms-admin', 'p99')", "label": "p99", "id": "e2" } ],
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer, TargetGroup} MetricName=\"TargetResponseTime\" forms-admin', 'Maximum')", "label": "Max", "id": "e3" } ]
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
            "height": 5,
            "width": 12,
            "y": 37,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer} MetricName=\"ProcessedBytes\" forms-${environment_name}', 'Sum')", "label": "Sum", "id": "e1" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ALB Traffic metrics (ProcessedBytes)",
                "period": 300,
                "stat": "Sum"
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
                "stat": "Average",
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
                "metrics": [
                    [ "AWS/ElastiCache", "DatabaseMemoryUsagePercentage", { "region": "eu-west-2" } ],
                    [ { "expression": "SEARCH('{AWS/ElastiCache, CacheClusterId} MetricName=\"DatabaseMemoryUsagePercentage\" forms-runner-${environment_name}', 'Average')", "id": "e1" } ]
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
            "height": 6,
            "width": 8,
            "y": 31,
            "x": 16,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ElastiCache", "CurrItems", { "region": "eu-west-2" } ],
                    [ ".", "Evictions", { "region": "eu-west-2" } ],
                    [ { "expression": "SEARCH('{AWS/ElastiCache, CacheClusterId, CacheNodeId} MetricName=\"CurrItems\" forms-runner-${environment_name}', 'Maximum')", "id": "e1" } ],
                    [ { "expression": "SEARCH('{AWS/ElastiCache, CacheClusterId, CacheNodeId} MetricName=\"Evictions\" forms-runner-${environment_name}', 'Maximum')", "id": "e2" } ]
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
            "width": 8,
            "y": 25,
            "x": 16,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ElastiCache", "CurrConnections", { "region": "eu-west-2" } ],
                    [ ".", "NewConnections", { "region": "eu-west-2" } ],
                    [ { "expression": "SEARCH('{AWS/ElastiCache, CacheClusterId} MetricName=\"CurrConnections\" forms-runner-${environment_name}', 'Maximum')", "id": "e1" } ],
                    [ { "expression": "SEARCH('{AWS/ElastiCache, CacheClusterId} MetricName=\"NewConnections\" forms-runner-${environment_name}', 'Maximum')", "id": "e2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "Redis Current/NewConnections",
                "period": 300,
                "stat": "Average"
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
                    [ "ECS/ContainerInsights", "RunningTaskCount", "ServiceName", "forms-admin", "ClusterName", "forms-${environment_name}", { "region": "eu-west-2" } ],
                    [ ".", "DesiredTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "PendingTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ECS Pending/Running Task Count - Forms Admin",
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
            "y": 48,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/SES", "Delivery", { "region": "eu-west-2" } ],
                    [ ".", "Send", { "region": "eu-west-2" } ]
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
            "height": 3,
            "width": 12,
            "y": 6,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "RunningTaskCount", "ServiceName", "forms-runner", "ClusterName", "forms-${environment_name}", { "region": "eu-west-2" } ],
                    [ ".", "DesiredTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "PendingTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ]
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
            "y": 6,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "RunningTaskCount", "ServiceName", "forms-product-page", "ClusterName", "forms-${environment_name}", { "region": "eu-west-2" } ],
                    [ ".", "DesiredTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "PendingTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ECS Pending/Running Task Count - Forms-Product-page",
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
                    [ "ECS/ContainerInsights", "RunningTaskCount", "ServiceName", "forms-api", "ClusterName", "forms-${environment_name}", { "region": "eu-west-2" } ],
                    [ ".", "DesiredTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ],
                    [ ".", "PendingTaskCount", ".", ".", ".", ".", { "region": "eu-west-2" } ]
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
            "height": 6,
            "width": 6,
            "y": 42,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer, TargetGroup} MetricName=\"TargetResponseTime\" forms-runner', 'Average')", "label": "Average", "id": "e1" } ],
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer, TargetGroup} MetricName=\"TargetResponseTime\" forms-runner', 'p99')", "label": "p99", "id": "e2" } ],
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer, TargetGroup} MetricName=\"TargetResponseTime\" forms-runner', 'Maximum')", "label": "Max", "id": "e3" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ALB Forms-runner Latency metrics (Target Response Time)",
                "period": 60,
                "stat": "Maximum"
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 42,
            "x": 18,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer, TargetGroup} MetricName=\"TargetResponseTime\" forms-product-page', 'Average')", "label": "Average", "id": "e1" } ],
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer, TargetGroup} MetricName=\"TargetResponseTime\" forms-product-page', 'p99')", "label": "p99", "id": "e2" } ],
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer, TargetGroup} MetricName=\"TargetResponseTime\" forms-product-page', 'Maximum')", "label": "Max", "id": "e3" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ALB Forms-Product-page Latency (Target Response Time)",
                "period": 60,
                "stat": "Maximum"
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 42,
            "x": 6,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer, TargetGroup} MetricName=\"TargetResponseTime\" forms-api', 'Average')", "label": "Average", "id": "e1" } ],
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer, TargetGroup} MetricName=\"TargetResponseTime\" forms-api', 'p99')", "label": "p99", "id": "e2" } ],
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer, TargetGroup} MetricName=\"TargetResponseTime\" forms-api', 'Maximum')", "label": "Max", "id": "e3" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ALB Forms-api Latency (Target Response Time)",
                "period": 60,
                "stat": "Maximum"
            }
        },
        {
            "height": 5,
            "width": 12,
            "y": 37,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer} MetricName=\"NewConnectionCount\" forms-${environment_name}', 'Average')", "id": "e1" } ],
                    [ { "expression": "SEARCH('{AWS/ApplicationELB, LoadBalancer} MetricName=\"ActiveConnectionCount\" forms-${environment_name}', 'Average')", "id": "e2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "ALB Active/New Connection Count",
                "period": 300,
                "stat": "Average"
            }
        }
    ]
}
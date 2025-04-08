{
    "widgets": [
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "expression": "m1/1000", "label": "Average", "id": "e1", "region": "eu-west-2", "period": 300 } ],
                    [ { "expression": "m2/1000", "label": "p99", "id": "e2", "region": "eu-west-2", "period": 300 } ],
                    [ { "expression": "m3/1000", "label": "Maximum", "id": "e3", "region": "eu-west-2", "period": 300 } ],
                    [ "Forms/Jobs", "TimeToSendSubmission", "ServiceName", "forms-runner", "JobName", "SendSubmissionJob", "Environment", "${environment_name}", { "stat": "Average", "region": "eu-west-2", "label": "Average", "id": "m1", "visible": false } ],
                    [ "...", { "region": "eu-west-2", "label": "p99", "id": "m2", "visible": false } ],
                    [ "...", { "stat": "Maximum", "region": "eu-west-2", "label": "Maximum", "id": "m3", "visible": false } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "period": 300,
                "stat": "p99",
                "title": "The time to send a submission from the time it was scheduled to be sent",
                "yAxis": {
                    "left": {
                        "label": "Seconds",
                        "showUnits": false
                    }
                }
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 6,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "Forms/Jobs", "TimeToSendSubmission", "ServiceName", "forms-runner", "JobName", "SendSubmissionJob", "Environment", "${environment_name}", { "region": "eu-west-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "Number of submissions sent",
                "stat": "SampleCount",
                "period": 3600
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 6,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "Forms/Jobs", "Failure", "ServiceName", "forms-runner", "JobName", "SendSubmissionJob", "Environment", "${environment_name}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "stat": "Sum",
                "period": 300,
                "title": "Failures sending submissions"
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "Forms/Jobs", "QueueLength", "ServiceName", "forms-runner", "Environment", "${environment_name}", "QueueName", "submissions", { "region": "eu-west-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "title": "Submissions queue length",
                "region": "us-east-1",
                "period": 60,
                "stat": "Average",
                "yAxis": {
                    "left": {
                        "label": "Length",
                        "showUnits": false
                    }
                }
            }
        }
    ]
}
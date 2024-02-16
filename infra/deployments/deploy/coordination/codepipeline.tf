module "log_codepipeline_events" {
    source = "../../../modules/eventbridge-log-to-cloudwatch"

    environment_name  = "deploy"
    log_group_subject = "codepipeline"

    event_pattern = jsonencode({
        source = ["aws.codepipeline"]
    })
}
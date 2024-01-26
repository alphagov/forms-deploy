data "aws_cloudwatch_event_bus" "default" {
    name = "default"    
}

data "aws_iam_policy_document" "allow_receiving_from_other_accounts" {
    dynamic "statement" {
        for_each = {
            "development" = "498160065950",
            "staging" = "972536609845",
            "production" = "443944947292",
            "user_research" = "619109835131"
        }
        
        content {
            sid = "allow_events_from_${statement.key}"
            effect = "Allow"
            actions = [
                "events:PutEvents"    
            ]
            resources = [data.aws_cloudwatch_event_bus.default.arn]
            principals {
              type = "AWS"
              identifiers = [statement.value]
            }
        }
    }
}

resource "aws_cloudwatch_event_bus_policy" "default_bus_policy" {
    policy = data.aws_iam_policy_document.allow_receiving_from_other_accounts.json
    event_bus_name = "default"
}
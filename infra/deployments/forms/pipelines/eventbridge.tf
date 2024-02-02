data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

data "aws_iam_policy_document" "allow_receiving_from_deploy_account" {
  statement {
    sid    = "AllowEventsFromDeployAcct"
    effect = "Allow"
    actions = [
      "events:PutEvents"
    ]
    resources = [data.aws_cloudwatch_event_bus.default.arn]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::711966560482:root"]
    }
  }
}

resource "aws_cloudwatch_event_bus_policy" "default_bus_policy" {
  policy         = data.aws_iam_policy_document.allow_receiving_from_deploy_account.json
  event_bus_name = "default"
}
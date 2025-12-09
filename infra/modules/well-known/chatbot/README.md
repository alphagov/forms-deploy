# Well-Known ChatBot Module

This module provides well-known names and ARNs for AWS ChatBot SNS topics that are created in the deploy account and can be referenced from other accounts.

## Purpose

1. Defines the SNS topic names as constants
2. Constructs the ARNs using the deploy account ID
3. Allows other deployments to reference these topics without using remote state

## Usage

### In the Deploy Account (Creating the Topics)

```hcl
module "chatbot_well_known" {
  source = "../../../modules/well-known/chatbot"
}

resource "aws_sns_topic" "alerts_topic" {
  name = module.chatbot_well_known.alerts_topic_name
  # ... other configuration
}

resource "aws_sns_topic" "deployments_topic" {
  name = module.chatbot_well_known.deployments_topic_name
  # ... other configuration
}
```

### In Other Accounts (Referencing the Topics)

```hcl
module "chatbot_well_known" {
  source = "../../../modules/well-known/chatbot"
}

# Use the ARNs in your resources
resource "aws_cloudwatch_metric_alarm" "example" {
  alarm_actions = [module.chatbot_well_known.alerts_topic_arn]
  # ... other configuration
}

# Or use in SNS topic subscriptions, EventBridge targets, etc.
resource "aws_sns_topic_subscription" "example" {
  topic_arn = module.chatbot_well_known.deployments_topic_arn
  # ... other configuration
}
```

## Outputs

- `alerts_topic_name` - Name of the SNS topic for the alerts channel
- `alerts_topic_arn` - ARN of the SNS topic for the alerts channel
- `deployments_topic_name` - Name of the SNS topic for the deployments channel
- `deployments_topic_arn` - ARN of the SNS topic for the deployments channel

## Note

The actual SNS topics are created in `deploy/coordination/notifications.tf`. This module only provides the well-known names and ARNs for reference.

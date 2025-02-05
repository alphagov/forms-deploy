resource "aws_sesv2_email_identity" "from_address" {
  email_identity = var.from_address

  # Default configuration set name.
  # It can be overridden when sending mail.
  #
  # Default is Auth0 set because Auth0 sends via
  # SMTP and does not set the required headers.
  configuration_set_name = aws_sesv2_configuration_set.auth0.configuration_set_name
}

##
# SES v2 configuration
##
resource "aws_sesv2_configuration_set" "auth0" {
  configuration_set_name = "${var.environment_name}_auth0"

  reputation_options {
    reputation_metrics_enabled = true
  }
}

resource "aws_sesv2_configuration_set_event_destination" "auth0" {
  configuration_set_name = aws_sesv2_configuration_set.auth0.configuration_set_name
  event_destination_name = "auth0_bounces_and_complaints"

  event_destination {
    enabled              = true
    matching_event_types = ["BOUNCE", "COMPLAINT", "REJECT"]

    sns_destination {
      topic_arn = aws_sns_topic.ses_bounces_and_complaints.arn
    }
  }
}

resource "aws_sesv2_configuration_set" "form_submissions" {
  configuration_set_name = "${var.environment_name}_form_submissions"

  reputation_options {
    reputation_metrics_enabled = true
  }
}


##
# SES v1 configuration
##
resource "aws_ses_event_destination" "failed_email_notification" {
  name                   = "failed_email_notification"
  configuration_set_name = aws_ses_configuration_set.bounces_and_complaints_handling_rule.name
  enabled                = true
  matching_types         = ["bounce", "complaint", "reject"]

  sns_destination {
    topic_arn = aws_sns_topic.ses_bounces_and_complaints.arn
  }
}

resource "aws_ses_configuration_set" "bounces_and_complaints_handling_rule" {
  #checkov:skip=CKV_AWS_365 We'll look at this later
  name = "bounces_and_complaints_handling_rule"

  reputation_metrics_enabled = true
}

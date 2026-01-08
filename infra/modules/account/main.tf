# The Security alternate contact for all our accounts is set by the Engineering Enablement team
# https://github.com/alphagov/gds-aws-organisation-accounts/blob/a82a7eb3604cd192261434dee4ad9f8bae8db25f/terraform/modules/org-account/main.tf#L46-L52
resource "aws_account_alternate_contact" "operations" {
  alternate_contact_type = "OPERATIONS"
  name                   = "GOV.UK Forms Infrastructure Team"
  title                  = "Infra Team"
  email_address          = data.aws_ssm_parameter.contact_email.value
  phone_number           = data.aws_ssm_parameter.contact_phone_number.value
}

resource "aws_ssm_parameter" "contact_email" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name  = "/account/contact-email"
  type  = "SecureString"
  value = "dummy-email-address@digital.cabinet-office.gov.uk"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "contact_phone_number" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name  = "/account/contact-phone-number"
  type  = "SecureString"
  value = "+1234567890"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

data "aws_ssm_parameter" "contact_phone_number" {
  name = "/account/contact-phone-number"

  depends_on = [aws_ssm_parameter.contact_phone_number]
}

data "aws_ssm_parameter" "contact_email" {
  name = "/account/contact-email"

  depends_on = [aws_ssm_parameter.contact_email]
}

resource "aws_iam_account_password_policy" "strong" {
  #checkov:skip=CKV_AWS_9:requiring password reset can be counterproductive https://www.ncsc.gov.uk/collection/passwords/updating-your-approach

  # Cyber security policies https://sites.google.com/cabinetoffice.gov.uk/cybersecurity/cyber-security-policies/cyber-security-policies?pli=1
  # "User accounts must be secured with a password or PIN with a minimum length of 10 characters."
  # "Administrator accounts must be secured with a password or PIN with a minimum length of 14 characters."
  minimum_password_length      = 14 # checkov nudges us towards 14
  require_lowercase_characters = true
  require_numbers              = true
  require_uppercase_characters = true
  require_symbols              = true

  password_reuse_prevention      = 24 # prevent use from re-using our last 24 passwords
  allow_users_to_change_password = true
}

data "aws_account_primary_contact" "current" {}

locals {
  // We'll set the account alias to the full name of the primary contact if it's set
  // convention dictates that this will be set to the same value as the account name.
  // If https://github.com/hashicorp/terraform-provider-aws/pull/44085 is released we can
  // use that instead.
  account_alias = data.aws_account_primary_contact.current.full_name != null ? data.aws_account_primary_contact.current.full_name : ""
}

resource "aws_iam_account_alias" "alias" {
  // Only create the alias if we have a valid value to set it to
  count = can(regex("^[a-zA-Z0-9-]+$", local.account_alias)) ? 1 : 0

  account_alias = local.account_alias
}

# AWS Cost Optimization and Compute Optimizer Enrollment
#
# These services SHOULD be managed by the following Terraform resources:
#   - aws_costoptimizationhub_enrollment_status (for Cost Optimization Hub)
#   - aws_computeoptimizer_enrollment_status (for Compute Optimizer)
#
# However, the Cost Optimization Hub resource has drift issues that cause Terraform to
# always show changes. See: https://github.com/hashicorp/terraform-provider-aws/issues/39520
#
# For consistency, both Cost Optimization Hub and Compute Optimizer enrollment are
# managed together via post-apply hook scripts in the account deployment roots:
#   - infra/deployments/forms/account/post-apply.sh
#   - infra/deployments/deploy/account/post-apply.sh (symlinked to forms)
#
# When the Cost Optimization Hub drift issue is resolved, both resources can be
# uncommented below and the enrollment logic removed from the post-apply scripts.

# resource "aws_costoptimizationhub_enrollment_status" "enroll_coh" {
#   include_member_accounts = false
# }

# resource "aws_computeoptimizer_enrollment_status" "enroll_co" {
#   status                  = "Active"
#   include_member_accounts = false
# }

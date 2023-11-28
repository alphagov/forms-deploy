locals {
  co_email        = "/@(digital[.])?cabinet-?office.gov.uk/"
  role_prefix     = replace(var.email, local.co_email, "")
  role_name       = "${local.role_prefix}-${var.role_suffix}"
  trust_principal = "arn:aws:iam::622626885786:user/${var.email}"
}

resource "aws_iam_role" "gds_user_role" {
  name = local.role_name

  max_session_duration = var.max_session_duration

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "AWS"
      identifiers = [local.trust_principal]
    }
    effect = "Allow"

    condition {
      test     = "Bool"
      values   = ["true"]
      variable = "aws:MultiFactorAuthPresent"
    }


    dynamic "condition" {
      for_each = length(var.ip_restrictions) > 0 ? [1] : []
      content {
        test     = "IpAddress"
        values   = var.ip_restrictions
        variable = "aws:SourceIp"
      }
    }
  }
}

resource "aws_iam_role_policy_attachment" "gds_user_role_policy_attachments" {
  #checkov:skip=CKV_AWS_274:We're OK with AdministratorAccess being attached, and we have controls in place to manage who it gets attached to

  count      = length(var.iam_policy_arns)
  role       = aws_iam_role.gds_user_role.name
  policy_arn = element(var.iam_policy_arns, count.index)
}

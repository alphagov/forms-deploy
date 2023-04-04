locals {
  co_email        = "/@(digital[.])?cabinet-?office.gov.uk/"
  role_prefix     = replace(var.email, local.co_email, "")
  role_name       = "${local.role_prefix}-${var.role_suffix}"
  trust_principal = "arn:aws:iam::622626885786:user/${var.email}"

  permitted_source_ips = [
    "213.86.153.211/32",
    "213.86.153.212/32",
    "213.86.153.213/32",
    "213.86.153.214/32",
    "213.86.153.231/32",
    "213.86.153.235/32",
    "213.86.153.236/32",
    "213.86.153.237/32",
    "51.149.8.0/25",
    "51.149.8.128/29",
    "51.149.9.112/29",
    "51.149.9.240/29"
  ]
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
      for_each = var.restrict_to_gds_ips ? [1] : []
      content {
        test     = "IpAddress"
        values   = local.permitted_source_ips
        variable = "aws:SourceIp"
      }
    }
  }
}

resource "aws_iam_role_policy_attachment" "gds_user_role_policy_attachments" {
  count      = length(var.iam_policy_arns)
  role       = aws_iam_role.gds_user_role.name
  policy_arn = element(var.iam_policy_arns, count.index)
}

locals {
  co_email        = "/@(digital[.])?cabinet-?office.gov.uk/"
  role_prefix     = replace(var.email, local.co_email, "")
  role_name       = "${local.role_prefix}-${var.role_suffix}"
  trust_principal = "arn:aws:iam::622626885786:user/${var.email}"

  gds_ip_restriction_policy_fragment = <<-EOF
  "IpAddress": {
    "aws:SourceIp": [
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
  },
  EOF

  maybe_source_ip_restriction = "${
    var.restrict_to_gds_ips
    ? local.gds_ip_restriction_policy_fragment
    : ""
  }"
}

resource "aws_iam_role" "gds_user_role" {
  name = local.role_name

  max_session_duration = var.max_session_duration

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "${local.trust_principal}"
          ]
        },
        "Action": "sts:AssumeRole",
        "Condition": {
          ${local.maybe_source_ip_restriction}
          "Bool": {
            "aws:MultiFactorAuthPresent": "true"
          }
        }
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "gds_user_role_policy_attachments" {
  count = length(var.iam_policy_arns)
  role  = aws_iam_role.gds_user_role.name
  policy_arn = element(var.iam_policy_arns, count.index)
}

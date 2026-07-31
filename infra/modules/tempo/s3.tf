module "trace_storage" {
  source = "../secure-bucket"

  name = "forms-tempo-traces-${var.env_name}"
}

# Minimal permissions documented at:
# https://grafana.com/docs/tempo/latest/configuration/hosted-storage/s3/#iam-policy
data "aws_iam_policy_document" "tempo_s3_access" {
  statement {
    sid    = "TempoTraceStorage"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging",
    ]
    resources = [
      module.trace_storage.arn,
      "${module.trace_storage.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "tempo_s3_access" {
  name   = "${var.env_name}-tempo-s3-access"
  policy = data.aws_iam_policy_document.tempo_s3_access.json
}

resource "aws_iam_role_policy_attachment" "tempo_s3_access" {
  role       = aws_iam_role.tempo_task.name
  policy_arn = aws_iam_policy.tempo_s3_access.arn
}

module "mimir_storage" {
  source = "../secure-bucket"

  name = "forms-tempo-mimir-${var.env_name}"
}

data "aws_iam_policy_document" "mimir_s3_access" {
  statement {
    sid    = "MimirBlockStorage"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging",
    ]
    resources = [
      module.mimir_storage.arn,
      "${module.mimir_storage.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "mimir_s3_access" {
  name   = "${var.env_name}-tempo-mimir-s3-access"
  policy = data.aws_iam_policy_document.mimir_s3_access.json
}

resource "aws_iam_role_policy_attachment" "mimir_s3_access" {
  role       = aws_iam_role.mimir_task.name
  policy_arn = aws_iam_policy.mimir_s3_access.arn
}

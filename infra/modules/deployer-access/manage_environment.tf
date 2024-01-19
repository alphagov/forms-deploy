data "aws_iam_policy_document" "environment" {
  source_policy_documents = [
    data.aws_iam_policy_document.acm-cert-with-dns-validation.json,
    data.aws_iam_policy_document.cloudfront.json,
    data.aws_iam_policy_document.public-bucket.json,
    data.aws_iam_policy_document.secure-bucket.json,
  ]
}

resource "aws_iam_policy" "environment" {
  policy = data.aws_iam_policy_document.environment.json
}

resource "aws_iam_role_policy_attachment" "environment" {
  policy_arn = aws_iam_policy.environment.arn
  role       = aws_iam_role.deployer.id
}

data "aws_iam_policy_document" "acm-cert-with-dns-validation" {
  statement {
    sid    = "ManageCertificates"
    effect = "Allow"
    actions = [
      "acm:AddTagsToCertificate",
      "acm:DeleteCertificate",
      "acm:DescribeCertificate",
      "acm:GetCertificate",
      "acm:ListTagsForCertificate",
      "acm:RemoveTagsFromCertificate",
    ]
    resources = [
      # TODO: Why does it need both regions?
      "arn:aws:acm:eu-west-2:${lookup(local.account_ids, var.env_name)}:certificate/*",
      "arn:aws:acm:us-east-1:${lookup(local.account_ids, var.env_name)}:certificate/*"
    ]
  }

  statement {
    sid    = "ListHostedZones"
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
    ]
    resources = [
      "*"
    ]
  }

  # duplicate
  statement {
    sid    = "ManageRoute53RecordSets"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${var.hosted_zone_id}"
    ]
  }
}

data "aws_iam_policy_document" "cloudfront" {
  statement {
    sid    = "ManageCloudfrontDistribution"
    effect = "Allow"
    actions = [
      "cloudfront:AssociateAlias",
      "cloudfront:CreateDistribution",
      "cloudfront:DeleteDistribution",
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:TagResource",
      "cloudfront:UntagResource",
      "cloudfront:UpdateDistribution",
    ]
    resources = [
      "arn:aws:cloudfront::${lookup(local.account_ids, var.env_name)}:distribution/*"
    ]
  }

  statement {
    sid    = "GetPoliciesCloudfront"
    effect = "Allow"
    actions = [
      "cloudfront:GetResponseHeadersPolicy",
      "cloudfront:GetCachePolicy",
      "cloudfront:GetOriginRequestPolicy",
      "cloudfront:ListResponseHeadersPolicies",
      "cloudfront:ListCachePolicies",
      "cloudfront:ListOriginRequestPolicies",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "ManageWAFv2WebACL"
    effect = "Allow"
    actions = [
      "wafv2:CreateWebACL",
      "wafv2:GetWebACL",
      "wafv2:DeleteLoggingConfiguration",
      "wafv2:DeleteWebACL",
      "wafv2:GetLoggingConfiguration",
      "wafv2:ListTagsForResource",
      "wafv2:PutLoggingConfiguration",
      "wafv2:TagResource",
      "wafv2:UntagResource",
      "wafv2:UpdateWebACL",
    ]
    # TODO: The scope of this should be cloudfront but for some reason it needs global
    resources = [
      "arn:aws:wafv2:us-east-1:${lookup(local.account_ids, var.env_name)}:global/webacl/cloudfront_waf_${var.env_name}/*"
    ]
  }

  statement {
    sid    = "ManageCloudwatchLogsWAF"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DeleteLogGroup",
      "logs:ListTagsLogGroup",
      "logs:TagLogGroup",
      "logs:UntagLogGroup",
    ]
    resources = [
      "arn:aws:logs:us-east-1:${lookup(local.account_ids, var.env_name)}:log-group:aws-waf-logs-${var.env_name}"
    ]
  }

  statement {
    sid    = "ManageCloudwatchLogStreamsWAF"
    effect = "Allow"
    actions = [
      "logs:ListTagsLogGroup",
      "logs:TagLogGroup",
      "logs:UntagLogGroup",
    ]
    resources = [
      "arn:aws:logs:us-east-1:${lookup(local.account_ids, var.env_name)}:log-group:aws-waf-logs-${var.env_name}:log-stream:*"
    ]
  }


  statement {
    sid    = "ManageCloudwatchLogSubscriptionFiltersWAF"
    effect = "Allow"
    actions = [
      "logs:DeleteSubscriptionFilter",
      "logs:DescribeSubscriptionFilters",
      "logs:PutSubscriptionFilter",
    ]
    resources = [
      "arn:aws:logs:us-east-1:${lookup(local.account_ids, var.env_name)}:log-group:aws-waf-logs-${var.env_name}:*"

    ]
  }

}

data "aws_iam_policy_document" "public-bucket" {
  statement {
    sid    = "ManageErrorPageBucket"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:DeleteBucketWebsite",
      "s3:GetAccelerateConfiguration",
      "s3:GetAnalyticsConfiguration",
      "s3:GetBucket*",
      "s3:GetEncryptionConfiguration",
      "s3:GetInventoryConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetMetricsConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
      "s3:PutBucketOwnershipControls",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketTagging",
      "s3:PutBucketVersioning",
      "s3:PutBucketWebsite",
      "s3:PutEncryptionConfiguration",
    ]
    resources = [
      "arn:aws:s3:::govuk-forms-${var.env_name}-error-page"
    ]
  }

  statement {
    sid = "ManageErrorPageBucketObjects"
    effect = "Allow"
    actions = [
      "s3:DeleteOject*",
      "s3:GetObject*",
      "s3:PutObject*",
    ]
    resources = [
      "arn:aws:s3:::govuk-forms-${var.env_name}-error-page/*"
    ]
  }
}

data "aws_iam_policy_document" "secure-bucket" {
  statement {
    sid    = "ManageALBLogsBucket"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:DeleteBucketWebsite",
      "s3:GetAccelerateConfiguration",
      "s3:GetAnalyticsConfiguration",
      "s3:GetBucket*",
      "s3:GetEncryptionConfiguration",
      "s3:GetInventoryConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetMetricsConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
      "s3:PutBucketOwnershipControls",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketTagging",
      "s3:PutBucketVersioning",
      "s3:PutBucketWebsite",
    ]
    resources = [
      "arn:aws:s3:::govuk-forms-alb-logs-${var.env_name}"
    ]
  }

  statement {
    sid = "ManageALBLogsBucketObjects"
    effect = "Allow"
    actions = [
      "s3:DeleteOject*",
      "s3:GetObject*",
      "s3:PutObject*",
    ]
    resources = [
      "arn:aws:s3:::govuk-forms-alb-logs-${var.env_name}"
    ]
  }
}
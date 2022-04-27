#
# Custom Bucket Policy
#
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "custom_bucket_policy" {
  statement {
    sid    = "allow-ses-puts"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.test_name}/ses/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:Referer"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

#
# Private Bucket
#

module "s3_private_bucket" {
  source = "../../"

  bucket                   = var.test_name
  custom_bucket_policy     = data.aws_iam_policy_document.custom_bucket_policy.json
  use_account_alias_prefix = false
  logging_bucket           = var.logging_bucket

  depends_on = [
    module.s3_logs
  ]
}

#
# Logging Bucket
#

module "s3_logs" {
  source  = "trussworks/logs/aws"
  version = "~> 10"

  s3_bucket_name = var.logging_bucket

  default_allow = false
}

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
  logging_bucket           = module.s3_logs.aws_logs_bucket
  enable_bucket_inventory  = true
}

#
# Logging Bucket
#

module "s3_logs" {
  source  = "trussworks/logs/aws"
  version = "~> 4"

  s3_bucket_name = var.logging_bucket
  region         = var.region

  default_allow = false
}

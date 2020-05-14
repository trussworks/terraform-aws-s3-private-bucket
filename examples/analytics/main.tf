#
# Private Bucket
#

module "s3_private_bucket" {
  source = "../../"

  bucket                   = var.test_name
  use_account_alias_prefix = false
  logging_bucket           = module.s3_logs.aws_logs_bucket
}

#
# Analytics Bucket
#

module "s3_analytics" {
  source  = "trussworks/analytics/aws"
  version = "~> 4"

  s3_bucket_name = var.analytics_bucket
  region         = var.region

  default_allow = false
}

#
# Private Bucket
#

module "s3_private_bucket" {
  source = "../../"

  bucket                   = var.test_name
  use_account_alias_prefix = false
  logging_bucket           = var.logging_bucket
  enable_bucket_inventory  = true

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

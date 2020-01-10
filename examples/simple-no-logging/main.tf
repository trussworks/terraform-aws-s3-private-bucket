#
# Private Bucket
#

module "s3_private_bucket" {
  source = "../../"

  bucket                   = var.test_name
  use_account_alias_prefix = false
}

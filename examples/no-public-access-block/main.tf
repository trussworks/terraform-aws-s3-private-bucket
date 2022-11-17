#
# Private Bucket
#

module "s3_private_bucket" {
  source                        = "../../"
  bucket                        = var.test_name
  use_account_alias_prefix      = false
  enable_s3_public_access_block = false
}

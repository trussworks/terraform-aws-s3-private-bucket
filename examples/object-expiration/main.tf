#
# Private Bucket with object expiration
#

module "s3_private_bucket" {
  source = "../../"

  bucket                   = var.test_name
  use_account_alias_prefix = false

  abort_incomplete_multipart_upload_days = 7

  expiration = [
    {
      days = 7
      # when days pr date is set the expiration object delete marker cannot be set to true
      # if it is set to true then terraform plans will continue to attempt to set it each time a plan is applied
      expiration_object_delete_marker = false
    }
  ]
}

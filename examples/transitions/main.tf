#
# Private Bucket with transitions
#

module "s3_private_bucket" {
  source = "../../"

  bucket                   = var.test_name
  use_account_alias_prefix = false

  abort_incomplete_multipart_upload_days = 7

  transitions = [
    {
      days          = 30
      storage_class = "STANDARD_IA"
    },
    {
      days          = 60
      storage_class = "GLACIER"
    },
    {
      days          = 150
      storage_class = "DEEP_ARCHIVE"
    }
  ]

  noncurrent_version_transitions = [
    {
      days          = 30
      storage_class = "STANDARD_IA"
    },
    {
      days          = 60
      storage_class = "GLACIER"
    }
  ]
  noncurrent_version_expiration = 90
}

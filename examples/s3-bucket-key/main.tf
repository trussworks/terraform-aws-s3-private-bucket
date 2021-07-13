
#
# Private Bucket with encryption
#

module "aws_s3_bucket_kms_key" {
  source  = "dod-iac/s3-kms-key/aws"
  version = "~> 1.0.1"

  name        = format("alias/%s-s3-key", var.test_name)
  description = format("S3 KMS key for %s", var.test_name)
  principals  = ["*"]
}

module "s3_private_bucket" {
  source = "../../"

  bucket                   = var.test_name
  use_account_alias_prefix = false

  kms_master_key_id  = module.aws_s3_bucket_kms_key.aws_kms_key_arn
  sse_algorithm      = "aws:kms"
  bucket_key_enabled = true
}

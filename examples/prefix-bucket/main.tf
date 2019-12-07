#
# Private Bucket
#

module "s3_private_bucket" {
  source = "../../"

  bucket_prefix  = var.test_prefix
  bucket         = var.test_name
  logging_bucket = module.s3_logs.aws_logs_bucket
  use_prefix     = true
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

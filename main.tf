/**
 * Creates a private S3 bucket with good defaults:
 *
 * * Private only objects
 * * Encryption
 * * Versioning
 * * Access logging
 *
 * The following policy rules are set:
 *
 * * Deny uploading public objects.
 * * Deny updating policy to allow public objects.
 *
 * The following ACL rules are set:
 *
 * * Retroactively remove public access granted through public ACLs
 * * Deny updating ACL to public
 *
 * The following lifecycle rules are set:
 *
 * * Incomplete multipart uploads are deleted after 14 days.
 * * Expired object delete markers are deleted.
 * * Noncurrent object versions transition to the Standard - Infrequent Access storage class after 30 days.
 * * Noncurrent object versions expire after 365 days.
 *
 * ## Usage
 *
 *     module "aws-s3-bucket" {
 *       source         = "trussworks/s3-private-bucket/aws"
 *       bucket         = "my-bucket-name"
 *       logging_bucket = "my-aws-logs"
 *
 *       tags {
 *         Name        = "My bucket"
 *         Environment = "Dev"
 *       }
 *     }
 */

data "aws_iam_account_alias" "current" {}

locals {
  bucket_id = "${data.aws_iam_account_alias.current.account_alias}-${var.bucket}"
}

resource "aws_s3_bucket" "private_bucket" {
  bucket = "${local.bucket_id}"
  acl    = "private"
  tags   = "${var.tags}"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    abort_incomplete_multipart_upload_days = 14

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      days = 365
    }
  }

  logging {
    target_bucket = "${var.logging_bucket}"
    target_prefix = "s3/${local.bucket_id}/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = "${aws_s3_bucket.private_bucket.id}"

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}

/**
 * Creates a private, versioned S3 bucket with good defaults.
 *
 * The following lifecycle policies are set:
 *
 * * Incomplete multipart uploads are deleted after 14 days.
 * * Expired object delete markers are deleted.
 * * Noncurrent object versions transition to the Standard - Infrequent Access storage class after 30 days.
 * * Noncurrent object versions expire after 365 days.
 *
 * Usage:
 *
 *     module "aws-s3-bucket" {
 *       source = "github.com/trussworks/terraform-aws-s3-bucket"
 *       bucket = "my-versioning-bucket"
 *     }
 */

resource "aws_s3_bucket" "versioning_bucket" {
  bucket = "${var.bucket}"
  acl    = "private"

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
}

/**
 * Creates an S3 bucket with good default policies.
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
  acl    = "${var.acl}"

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

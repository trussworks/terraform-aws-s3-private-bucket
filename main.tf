/**
 * Creates a private, versioned S3 bucket with good defaults.
 *
 * The following policy rules are set:
 *
 * * Deny uploading public objects.
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
 *       source = "trussworks/s3-private-bucket/aws"
 *       bucket = "my-bucket-name"
 *     }
 */

data "aws_iam_account_alias" "current" {}

locals {
  bucket_id = "${data.aws_iam_account_alias.current.account_alias}-${var.bucket}"
}

data "template_file" "policy" {
  template = "${file("${path.module}/policy.tpl")}"

  vars {
    bucket = "${local.bucket_id}"
  }
}

resource "aws_s3_bucket" "private_bucket" {
  bucket = "${local.bucket_id}"
  acl    = "private"
  policy = "${data.template_file.policy.rendered}"

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

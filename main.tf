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
 *       source = "github.com/trussworks/terraform-aws-s3-bucket"
 *       bucket = "my-versioning-bucket"
 *     }
 */

data "aws_iam_account_alias" "current" {}

locals {
  bucket_name = "${data.aws_iam_account_alias.current.account_alias}-${var.bucket}"
}

resource "aws_s3_bucket" "private_bucket" {
  bucket = "${local.bucket_name}"
  acl    = "private"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "PutObjPolicy",
  "Statement": [
    {
      "Sid": "ensure-private-read-write",
      "Effect": "Deny",
      "Principal": "*",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": "arn:aws:s3:::${local.bucket_name}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": [
            "public-read",
            "public-read-write"
          ]
        }
      }
    }
  ]
}
POLICY

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

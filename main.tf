data "aws_iam_account_alias" "current" {
}

locals {
  bucket_prefix = var.use_account_alias_prefix ? format("%s-", data.aws_iam_account_alias.current.account_alias) : ""
  bucket_id     = "${local.bucket_prefix}${var.bucket}"
}

resource "aws_s3_bucket" "private_bucket" {
  bucket = local.bucket_id
  acl    = "private"
  policy = var.custom_bucket_policy
  tags   = var.tags

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

  dynamic "logging" {
    for_each = var.enable_bucket_logging ? [1] : []
    content {
      target_bucket = var.logging_bucket
      target_prefix = "s3/${local.bucket_id}/"
    }
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
  bucket = aws_s3_bucket.private_bucket.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}


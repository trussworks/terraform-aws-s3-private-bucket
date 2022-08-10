data "aws_iam_account_alias" "current" {
  count = var.use_account_alias_prefix ? 1 : 0
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  bucket_prefix         = var.use_account_alias_prefix ? format("%s-", data.aws_iam_account_alias.current[0].account_alias) : ""
  bucket_id             = "${local.bucket_prefix}${var.bucket}"
  enable_bucket_logging = var.logging_bucket != ""
}

data "aws_iam_policy_document" "supplemental_policy" {
  # This should be a single line:
  # source_policy_documents = [var.custom_bucket_policy]
  #
  # However, there appears to be a bug that occurs when source_policy_documents is an empty string:
  # - https://github.com/hashicorp/terraform-provider-aws/issues/22959
  # - https://github.com/hashicorp/terraform-provider-aws/issues/24366
  #
  # To work around this, we're using this workaround. It should be replaced
  # once the underlying issue is addressed.
  source_policy_documents = length(var.custom_bucket_policy) > 0 ? [var.custom_bucket_policy] : null

  # Enforce SSL/TLS on all transmitted objects
  # We do this by extending the custom_bucket_policy
  statement {
    sid = "enforce-tls-requests-only"

    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.bucket_id}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid = "inventory-and-analytics"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.bucket_id}/*"
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:s3:::${local.bucket_id}"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket" "private_bucket" {
  bucket        = var.use_random_suffix ? null : local.bucket_id
  bucket_prefix = var.use_random_suffix ? local.bucket_id : null
  tags          = var.tags
  force_destroy = var.enable_bucket_force_destroy

  lifecycle {
    # These lifecycle ignore_changes rules exist to permit a smooth upgrade
    # path from version 3.x of the AWS provider to version 4.x
    ignore_changes = [
      # While no special usage instructions are documented for needing this
      # ignore_changes rule, changes are still detected during the upgrade
      # process, so this serves to avoid drift detection since the
      # aws_s3_bucket_policy will be used instead.
      policy,

      # While no special usage instructions are documented for needing this
      # ignore_changes rule, this should avoid drift detection if conflicts
      # with the aws_s3_bucket_versioning exist.
      versioning,

      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_acl#usage-notes
      acceleration_status,
      acl,
      grant,

      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_cors_configuration#usage-notes
      cors_rule,

      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_lifecycle_configuration#usage-notes
      lifecycle_rule,

      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_logging#usage-notes
      logging,

      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_server_side_encryption_configuration#usage-notes
      server_side_encryption_configuration,
    ]
  }
}

resource "aws_s3_bucket_policy" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id
  policy = data.aws_iam_policy_document.supplemental_policy.json
}

resource "aws_s3_bucket_accelerate_configuration" "private_bucket" {
  count = var.transfer_acceleration != null ? 1 : 0

  bucket = aws_s3_bucket.private_bucket.id
  status = var.transfer_acceleration ? "Enabled" : "Suspended"
}

resource "aws_s3_bucket_acl" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  versioning_configuration {
    status = var.versioning_status
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    id = "abort-incomplete-multipart-upload"

    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = var.abort_incomplete_multipart_upload_days
    }

    dynamic "expiration" {
      for_each = var.expiration
      content {
        date = lookup(expiration.value, "date", null)
        days = lookup(expiration.value, "days", 0)

        expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", false)
      }
    }

    dynamic "transition" {
      for_each = var.transitions
      content {
        days          = transition.value.days
        storage_class = transition.value.storage_class
      }
    }

    dynamic "noncurrent_version_transition" {
      for_each = var.noncurrent_version_transitions
      content {
        noncurrent_days = noncurrent_version_transition.value.days
        storage_class   = noncurrent_version_transition.value.storage_class
      }
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration
    }
  }

  rule {
    id = "aws-bucket-inventory"

    status = "Enabled"

    filter {
      prefix = "_AWSBucketInventory/"
    }

    expiration {
      days = 14
    }
  }

  rule {
    id = "aws-bucket-analytics"

    status = "Enabled"

    filter {
      prefix = "_AWSBucketAnalytics/"
    }

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_logging" "private_bucket" {
  count = local.enable_bucket_logging ? 1 : 0

  bucket = aws_s3_bucket.private_bucket.id

  target_bucket = var.logging_bucket
  target_prefix = "s3/${local.bucket_id}/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = length(var.kms_master_key_id) > 0 ? var.kms_master_key_id : null
    }
    bucket_key_enabled = var.bucket_key_enabled
  }
}

resource "aws_s3_bucket_cors_configuration" "private_bucket" {
  count = length(var.cors_rules)

  bucket = aws_s3_bucket.private_bucket.bucket

  cors_rule {
    allowed_methods = var.cors_rules[count.index].allowed_methods
    allowed_origins = var.cors_rules[count.index].allowed_origins
    allowed_headers = lookup(var.cors_rules[count.index], "allowed_headers", null)
    expose_headers  = lookup(var.cors_rules[count.index], "expose_headers", null)
    max_age_seconds = lookup(var.cors_rules[count.index], "max_age_seconds", null)
  }
}

resource "aws_s3_bucket_analytics_configuration" "private_analytics_config" {
  count = var.enable_analytics ? 1 : 0

  bucket = aws_s3_bucket.private_bucket.bucket
  name   = "Analytics"

  storage_class_analysis {
    data_export {
      destination {
        s3_bucket_destination {
          bucket_arn = aws_s3_bucket.private_bucket.arn
          prefix     = "_AWSBucketAnalytics"
        }
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count = var.enable_s3_public_access_block ? 1 : 0

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

resource "aws_s3_bucket_inventory" "inventory" {
  count = var.enable_bucket_inventory ? 1 : 0

  bucket = aws_s3_bucket.private_bucket.id
  name   = "BucketInventory"

  included_object_versions = "All"

  schedule {
    frequency = var.schedule_frequency
  }

  destination {
    bucket {
      format     = var.inventory_bucket_format
      bucket_arn = aws_s3_bucket.private_bucket.arn
      prefix     = "_AWSBucketInventory/"
    }
  }

  optional_fields = ["Size", "LastModifiedDate", "StorageClass", "ETag", "IsMultipartUploaded", "ReplicationStatus", "EncryptionStatus",
  "ObjectLockRetainUntilDate", "ObjectLockMode", "ObjectLockLegalHoldStatus", "IntelligentTieringAccessTier"]
}

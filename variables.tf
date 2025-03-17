variable "abort_incomplete_multipart_upload_days" {
  description = "Number of days until aborting incomplete multipart uploads"
  type        = number
  default     = 14
}

variable "additional_lifecycle_rules" {
  description = "List of additional lifecycle rules to specify"
  type        = list(any)
  default     = []
}

variable "bucket" {
  description = "The name of the bucket."
  type        = string
}

variable "bucket_key_enabled" {
  description = "Whether or not to use Amazon S3 Bucket Keys for SSE-KMS."
  type        = bool
  default     = false
}

variable "control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls on this bucket."
  type        = bool
  default     = true
}

variable "cors_rules" {
  description = "List of maps containing rules for Cross-Origin Resource Sharing."
  type        = list(any)
  default     = []
}

variable "custom_bucket_policy" {
  description = "JSON formatted bucket policy to attach to the bucket."
  type        = string
  default     = ""
}

variable "enable_analytics" {
  description = "Enables storage class analytics on the bucket."
  default     = true
  type        = bool
}

variable "enable_bucket_force_destroy" {
  type        = bool
  default     = false
  description = "If set to true, Bucket will be emptied and destroyed when terraform destroy is run."
}

variable "enable_bucket_inventory" {
  type        = bool
  default     = false
  description = "If set to true, Bucket Inventory will be enabled."
}

variable "enable_s3_public_access_block" {
  description = "Bool for toggling whether the s3 public access block resource should be enabled."
  type        = bool
  default     = true
}

variable "inventory_bucket_format" {
  type        = string
  default     = "ORC"
  description = "The format for the inventory file. Default is ORC. Options are ORC or CSV."
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. If blank, bucket encryption configuration defaults to AES256."
  type        = string
  default     = ""
}

variable "lifecycle_abort_incomplete_upload" {
  description = "Default values for the abort incomplete mutlipart uploads lifecycle rule"
  default = {
    expiration = {
      expired_object_delete_marker = true
      days                         = null
      date                         = null
    }
    # No transition block necessary by default
    transition = null

    # noncurrent_version_transition (nvt) block attributes
    nvt = {
      newer_noncurrent_versions = null
      noncurrent_days           = 30
      storage_class             = "STANDARD_IA"
    }

    # noncurrent_version_expiration (nve) block attributes
    # Number of days until non-current version of object expires
    nve = {
      newer_noncurrent_versions = null,
      noncurrent_days           = 365
    }
  }
}

variable "lifecycle_aws_bucket_analytics_expiration" {
  description = "Number of days to keep aws bucket analytics objects"
  type        = number
  default     = 30
}

variable "lifecycle_aws_bucket_inventory_expiration" {
  description = "Number of days unused items expire from AWS Inventory"
  type        = number
  default     = 14
}

variable "logging_bucket" {
  description = "The S3 bucket to send S3 access logs."
  type        = string
  default     = ""
}

variable "object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter."
  type        = string
  default     = "BucketOwnerEnforced"
}

variable "s3_bucket_acl" {
  description = "Set bucket ACL per [AWS S3 Canned ACL](<https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl>) list."
  default     = null
  type        = string
}

variable "schedule_frequency" {
  type        = string
  default     = "Weekly"
  description = "The S3 bucket inventory frequency. Defaults to Weekly. Options are 'Weekly' or 'Daily'."
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  default     = {}
  type        = map(string)
}

variable "transfer_acceleration" {
  description = "Whether or not to enable bucket acceleration."
  type        = bool
  default     = null
}

variable "transition_default_minimum_object_size" {
  description = "Minimum object size to transition for lifecycle rule"
  type        = string
  default     = "all_storage_classes_128K"
}

variable "use_account_alias_prefix" {
  description = "Whether to prefix the bucket name with the AWS account alias."
  type        = bool
  default     = true
}

variable "use_random_suffix" {
  description = "Whether to add a random suffix to the bucket name."
  type        = bool
  default     = false
}

variable "versioning_status" {
  description = "A string that indicates the versioning status for the log bucket."
  default     = "Enabled"
  type        = string
  validation {
    condition     = contains(["Enabled", "Disabled", "Suspended"], var.versioning_status)
    error_message = "Valid values for versioning_status are Enabled, Disabled, or Suspended."
  }
}

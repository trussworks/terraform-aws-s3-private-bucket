variable "bucket" {
  description = "The name of the bucket."
  type        = string
}

variable "use_random_suffix" {
  description = "Whether to add a random suffix to the bucket name."
  type        = bool
  default     = false
}

variable "use_account_alias_prefix" {
  description = "Whether to prefix the bucket name with the AWS account alias."
  type        = string
  default     = true
}

variable "custom_bucket_policy" {
  description = "JSON formatted bucket policy to attach to the bucket."
  type        = string
  default     = ""
}

variable "logging_bucket" {
  description = "The S3 bucket to send S3 access logs."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  default     = {}
  type        = map(string)
}

variable "enable_bucket_inventory" {
  type        = bool
  default     = false
  description = "If set to true, Bucket Inventory will be enabled."
}

variable "enable_bucket_force_destroy" {
  type        = bool
  default     = false
  description = "If set to true, Bucket will be emptied and destroyed when terraform destroy is run."
}

variable "inventory_bucket_format" {
  type        = string
  default     = "ORC"
  description = "The format for the inventory file. Default is ORC. Options are ORC or CSV."
}

variable "schedule_frequency" {
  type        = string
  default     = "Weekly"
  description = "The S3 bucket inventory frequency. Defaults to Weekly. Options are 'Weekly' or 'Daily'."
}

variable "enable_analytics" {
  description = "Enables storage class analytics on the bucket."
  default     = true
  type        = bool
}

variable "cors_rules" {
  description = "List of maps containing rules for Cross-Origin Resource Sharing."
  type        = list(any)
  default     = []
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

variable "abort_incomplete_multipart_upload_days" {
  description = "Number of days until aborting incomplete multipart uploads"
  type        = number
  default     = 14
}

variable "expiration" {
  description = "expiration blocks"
  type        = list(any)
  default = [
    {
      expired_object_delete_marker = true
    }
  ]
}

variable "transitions" {
  description = "Current version transition blocks"
  type        = list(any)
  default     = []
}

variable "noncurrent_version_transitions" {
  description = "Non-current version transition blocks"
  type        = list(any)
  default = [
    {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  ]
}

variable "noncurrent_version_expiration" {
  description = "Number of days until non-current version of object expires"
  type        = number
  default     = 365
}

variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  type        = string
  default     = "AES256"
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption."
  type        = string
  default     = ""
}

variable "enable_s3_public_access_block" {
  description = "Bool for toggling whether the s3 public access block resource should be enabled."
  type        = bool
  default     = true
}

variable "bucket_key_enabled" {
  description = "Whether or not to use Amazon S3 Bucket Keys for SSE-KMS."
  type        = bool
  default     = false
}

variable "transfer_acceleration" {
  description = "Whether or not to enable bucket acceleration."
  type        = bool
  default     = null
}

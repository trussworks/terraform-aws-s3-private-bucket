variable "bucket" {
  description = "The name of the bucket."
  type        = string
}

variable "bucket_prefix" {
  description = "The prefix for the bucket."
  type        = string
  default     = ""
}

variable "use_prefix" {
  description = "Whether to prefix the bucket name with passed in variable."
  type        = bool
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
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  default     = {}
  type        = map(string)
}


variable "bucket" {
  description = "The name of the bucket. It will be prefixed with the AWS account alias."
  type        = "string"
}

variable "custom_bucket_policy" {
  description = "JSON formatted bucket policy to attach to the bucket."
  type        = "string"
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  default     = {}
  type        = "map"
}

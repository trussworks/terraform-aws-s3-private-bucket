variable "bucket" {
  description = "The name of the bucket. If omitted, Terraform will assign a random, unique name."
}

variable "acl" {
  description = "The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply."
  default     = "private"
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  default     = {}
}

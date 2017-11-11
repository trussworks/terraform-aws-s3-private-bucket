variable "bucket" {
  description = "The name of the bucket. It will be prefixed with the AWS account alias."
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  default     = {}
}

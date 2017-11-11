variable "bucket" {
  description = "The name of the bucket. If omitted, Terraform will assign a random, unique name."
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  default     = {}
}

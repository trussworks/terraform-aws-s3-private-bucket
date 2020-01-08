variable "test_name" {
  type = string
}

variable "logging_bucket" {
  type = string
}

variable "region" {
  type = string
}

variable "enable_bucket_logging" {
  type    = bool
  default = true
}

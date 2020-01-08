variable "test_name" {
  type = string
}

variable "logging_bucket" {
  type = string
}

variable "region" {
  type = string
}

variable "enable_bucket_inventory" {
  type    = bool
  default = false
}

variable "enable_bucket_logging" {
  type    = bool
  default = true
}

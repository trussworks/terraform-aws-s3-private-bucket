variable "test_name" {
  type = string
}

variable "logging_bucket" {
  type = string
}

variable "enable_analytics" {
  type = bool
}

variable "cors_rules" {
  type    = list(any)
  default = []
}

variable "versioning_status" {
  type = string
}

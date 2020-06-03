terraform {
  experiments = [variable_validation]
}


variable "instances_number" {
  description = "Number of instances to create"
  type = number
  default = 1
}

variable "volumes_number" {
  description = "Number of volumes to create"
  type = number
  default = 2

  validation {
    condition     = var.volumes_number <= 20
    error_message = "The number of volumes per instance cannot be greater then 20."
  }
}

locals {
  volumes_letters = [
    "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
  ]
}

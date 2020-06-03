terraform {
  experiments = [variable_validation]
}

locals {
  volumes_letters = [
    "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
  ]
  region = "eu-north-1"
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

variable "volume_type" {
  description = "Number of volumes to create"
  type    = string
  default    = "gp2"

  validation {
    condition     = can(regex("(^gp2$|^standard$|^io1$|^sc1$|^st1$)", var.volume_type))
    error_message = "The volume type must be one of the following 'standard', 'gp2', 'io1', 'sc1' or 'st1'."
  }
}

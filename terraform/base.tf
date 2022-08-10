terraform {
  required_version = ">=0.14"
}

variable "name" {
  type = string
}

variable "profile" {
  type = string
}

variable "credentials" {
  type = list(string)
}

variable "region" {
  type = string
}

variable "key_name" {
  type = string
}

variable "subnets" {
  type    = list(string)
  default = ["subnet-8a280df7", "subnet-c54d6588", "subnet-b85ab5d2"]
}

variable "vpc_id" {
  type    = string
  default = "vpc-68c6c103"
}


provider "aws" {
  profile                 = var.profile
  shared_credentials_file = var.credentials
  region                  = var.region
}

// Random resource for naming
resource "random_string" "rand" {
  length  = 8
  special = false
  upper   = false
}

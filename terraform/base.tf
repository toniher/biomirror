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

variable "db_engine" {
  type    = string
  default = "mariadb"
}

variable "db_version" {
  type    = string
  default = "10.5"
}

variable "db_instance" {
  type    = string
  default = "db.t3.medium"
}
variable "db_password" {
  type = string
}

variable "db_storage" {
  type    = number
  default = 250
}

variable "db_max_storage" {
  type    = number
  default = 1000
}

variable "db_port" {
  type    = number
  default = 3306
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

terraform {
  required_version = ">=0.14"
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

variable "availability_zones" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "subnets" {
  type    = list(string)
  default = ["subnet-8a280df7", "subnet-c54d6588", "subnet-b85ab5d2"]
}


variable "cidr" {
  type    = string
  default = "172.35.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["172.35.3.0/24", "172.35.4.0/24", "172.35.5.0/24"]
}

variable "vpc_id" {
  type    = string
  default = "vpc-68c6c103"
}

variable "route_table_id" {
  type    = string
  default = "rtb-1544fd7f"
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
  default = "db.t3.xlarge"
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

variable "db_name" {
  type    = string
  default = "biomirror"
}

variable "db_public_access" {
  type    = bool
  default = false
}

/* variable "db_subnet" {
  type = string
}

variable "db_availability_zone" {
  type = string
}

 */
# Bucket path where data is processed
variable "bucket_data_path" {
  type    = string
  default = "mybucket/output/mydata.gz"
}

# Bucket where to place scripts
variable "bucket_scripts" {
  type    = string
  default = "mybucket"
}

provider "aws" {
  profile                  = var.profile
  shared_credentials_files = var.credentials
  region                   = var.region
}

// Random resource for naming
resource "random_string" "rand" {
  length  = 8
  special = false
  upper   = false
}

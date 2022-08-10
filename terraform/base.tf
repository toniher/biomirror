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

resource "aws_db_subnet_group" "group_mariadb" {
  name       = "mariadb-subnet-${random_string.rand.result}"
  subnet_ids = var.subnets
}

resource "aws_db_instance" "mydb" {
  engine                 = var.db_engine
  engine_version         = var.db_version
  instance_class         = var.db_instance
  identifier             = "mariadb-instance-${random_string.rand.result}"
  username               = "root"
  password               = var.db_password
  parameter_group_name   = "default.${var.db_engine}${var.db_version}"
  db_subnet_group_name   = aws_db_subnet_group.group_mariadb.name
  vpc_security_group_ids = [aws_security_group.allow_mariadb.id]
  skip_final_snapshot    = true
  allocated_storage      = var.db_storage
  max_allocated_storage  = var.db_max_storage
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  // version = "3.14.2"

  name = "vpc-${random_string.rand.result}"
  cidr = var.cidr // var.db_cidr_blocks

  azs            = var.availability_zones
  public_subnets = var.public_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  // enable_nat_gateway = true
  // enable_vpn_gateway = true

  tags = {
    Name = "vpc-${random_string.rand.result}"
  }
}

# S3 endpoint needed for connection
resource "aws_vpc_endpoint" "s3_rds_glue" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"

  tags = {
    Endpoint = "VPC-RDS-Glue"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3_rds_glue_route_association" {
  route_table_id  = module.vpc.public_route_table_ids[0]
  vpc_endpoint_id = aws_vpc_endpoint.s3_rds_glue.id
}



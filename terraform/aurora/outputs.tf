output "database_name" {
  value = aws_rds_cluster.aurora_cluster.database_name
}

output "aurora_endpoint" {
  value = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_endpoint_read" {
  value = aws_rds_cluster.aurora_cluster.reader_endpoint
}

output "vpc_route_table_ids" {
  value = module.vpc.public_route_table_ids
}

output "vpc_subnet_ids" {
  value = module.vpc.public_subnets
}

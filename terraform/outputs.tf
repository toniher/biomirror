output "db_name" {
  value = aws_db_instance.mydb.db_name
}

output "db_instance_address" {
  value = aws_db_instance.mydb.address
}

output "db_instance_arn" {
  value = aws_db_instance.mydb.arn
}

output "db_instance_domain" {
  value = aws_db_instance.mydb.domain
}

output "db_instance_endpoint" {
  value = aws_db_instance.mydb.endpoint
}

output "db_instance_status" {
  value = aws_db_instance.mydb.status
}

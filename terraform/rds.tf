
resource "aws_db_subnet_group" "group_db" {
  name       = "db-subnet-${random_string.rand.result}"
  subnet_ids = var.subnets
}

resource "aws_db_instance" "mydb" {
  engine                 = var.db_engine
  engine_version         = var.db_version
  instance_class         = var.db_instance
  identifier             = "db-instance-${random_string.rand.result}"
  username               = "root"
  password               = var.db_password
  db_name                = var.db_name
  parameter_group_name   = "default.${var.db_engine}${var.db_version}"
  db_subnet_group_name   = aws_db_subnet_group.group_db.name
  vpc_security_group_ids = [aws_security_group.allow_db.id]
  skip_final_snapshot    = true
  allocated_storage      = var.db_storage
  max_allocated_storage  = var.db_max_storage
}
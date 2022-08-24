
resource "aws_db_subnet_group" "group_db" {
  name       = "db-subnet-${random_string.rand.result}"
  subnet_ids = module.vpc.public_subnets
}

/* // Temporary data of subnets based on: https://medium.com/@angielohqh/terraform-dynamically-look-up-vpc-requirements-for-aws-glue-connection-298662d10d89
data "aws_subnet" "mydb_subnets" {
  // https://stackoverflow.com/questions/62264013/terraform-failing-with-invalid-for-each-argument-the-given-for-each-argument
  for_each = toset(module.vpc.public_subnets)
  id       = each.value
} */

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
  publicly_accessible    = var.db_public_access
}
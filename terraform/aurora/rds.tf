
resource "aws_db_subnet_group" "group_db" {
  name       = "db-subnet-${random_string.rand.result}"
  subnet_ids = module.vpc.public_subnets
}

// Temporary data of subnets based on: https://medium.com/@angielohqh/terraform-dynamically-look-up-vpc-requirements-for-aws-glue-connection-298662d10d89
data "aws_subnet" "mydb_subnets" {
  // https://stackoverflow.com/questions/62264013/terraform-failing-with-invalid-for-each-argument-the-given-for-each-argument
  for_each   = toset(module.vpc.public_subnets)
  id         = each.value
  depends_on = [module.vpc]
}

/* resource "aws_db_instance" "mydb" {
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
} */

// Ref: https://gist.github.com/sandcastle/4e7b979c480690044bd8
// Ref: https://stackoverflow.com/questions/72060850/use-terraform-to-deploy-mysql-8-0-in-aws-aurora-v2
resource "aws_rds_cluster" "aurora_cluster" {

    cluster_identifier            = "aurora-cluster-${random_string.rand.result}"
    database_name                 = var.db_name
    master_username               = "root"
    master_password               = var.db_password
    // backup_retention_period       = 14
    // preferred_backup_window       = "02:00-03:00"
    // preferred_maintenance_window  = "wed:03:00-wed:04:00"
    // allocated_storage      =      var.db_storage

    db_subnet_group_name          = aws_db_subnet_group.group_db.name
    // final_snapshot_identifier     = "${var.environment_name}_aurora_cluster"
    vpc_security_group_ids = [aws_security_group.allow_db.id]

    engine                  = var.db_engine
    engine_version          = var.db_version

    lifecycle {
        create_before_destroy = true
    }

}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {

    count                 = 2
    identifier            = "aurora-instance-${random_string.rand.result}-${count.index}"
    cluster_identifier    = aws_rds_cluster.aurora_cluster.id
    instance_class        = var.db_instance
    db_subnet_group_name  = aws_db_subnet_group.group_db.name
    publicly_accessible   = var.db_public_access
    engine                = aws_rds_cluster.aurora_cluster.engine
    engine_version        = aws_rds_cluster.aurora_cluster.engine_version

    lifecycle {
        create_before_destroy = true
    }

}

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

resource "aws_rds_cluster_parameter_group" "mydb" {
  name        = "biomirror-aurora-${var.db_engine}${var.db_version}"
  family      = "aurora-${var.db_engine}${var.db_version}"
  description = "RDS cluster parameter group for biomirror"

  parameter {
    name  = "aurora_load_from_s3_role"
    value = aws_iam_role.rds_database_role.arn
  }
}

// Ref: https://gist.github.com/sandcastle/4e7b979c480690044bd8
// Ref: https://stackoverflow.com/questions/72060850/use-terraform-to-deploy-mysql-8-0-in-aws-aurora-v2
resource "aws_rds_cluster" "aurora_cluster" {

    cluster_identifier            = "aurora-cluster-${random_string.rand.result}"
    database_name                 = var.db_name
    master_username               = "root"
    master_password               = var.db_password

    iam_roles = [aws_iam_role.rds_database_role.arn]

    db_subnet_group_name          = aws_db_subnet_group.group_db.name
    vpc_security_group_ids = [aws_security_group.allow_db.id]
  
    skip_final_snapshot = true //TODO: We can change
    final_snapshot_identifier     = "aurora_cluster-${random_string.rand.result}"



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

//https://pixelswap.fr/entry/how-to-load-data-from-s3-in-aurora-mysql-db-using-terraform

resource "aws_iam_policy" "rds_s3_database_policy" {
  name   = "rds-database-policy-${random_string.rand.result}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:GetObjectVersion"],
      "Resource": "${data_s3_bucket.bucket_data.arn}/*"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "${data_s3_bucket.bucket_data.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role" "rds_database_role" {
  name               = "rds-database-role-${random_string.rand.result}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "rds_database" {
  role       = aws_iam_role.rds_database_role.name
  policy_arn = aws_iam_policy.rds_s3_database_policy.arn
}


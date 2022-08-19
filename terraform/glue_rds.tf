resource "aws_glue_catalog_database" "biomirror_rds_database" {
  name = "biomirror-rds-db-${random_string.rand.result}"
}

resource "aws_glue_connection" "biomirror_rds_connection" {

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:mysql://${aws_db_instance.mydb.endpoint}/${var.db_name}"
    PASSWORD            = var.db_password
    USERNAME            = "root"
  }

  name = "biomirror-rds-connection-${random_string.rand.result}"

  physical_connection_requirements {
    // TODO: address availability and subnet as separate params, sic
    availability_zone      = var.db_availability_zone
    security_group_id_list = [aws_security_group.allow_db_glue.id]
    subnet_id              = var.db_subnet
  }
}

resource "aws_glue_crawler" "biomirror_rds_crawler" {
  database_name = aws_glue_catalog_database.biomirror_rds_database.name
  name          = "biomirror-rds-crawler-${random_string.rand.result}"
  role          = aws_iam_role.glue-rds-role.arn

  jdbc_target {
    connection_name = aws_glue_connection.biomirror_rds_connection.name
    path            = "${var.db_name}/%"
  }
}

resource "aws_iam_role" "glue-rds-role" {
  name = "glue-rds-role-${random_string.rand.result}"

  assume_role_policy =  jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
  })

  tags = {
    Name = "Glue-RDS-Role"
  }
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRole-RDS-policy-attachment" {

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role      = aws_iam_role.glue-rds-role.name

}

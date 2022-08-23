# S3 endpoint needed for connection

resource "aws_vpc_endpoint" "s3_rds_glue" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"

  tags = {
    Endpoint = "RDS-Glue"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3_rds_glue_route_association" {
  route_table_id  = var.route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.s3_rds_glue.id
}


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
    availability_zone      = aws_db_instance.mydb.availability_zone
    security_group_id_list = [aws_security_group.allow_db_glue.id]
    subnet_id              = [for subnet in data.aws_subnet.mydb_subnets : subnet.id if subnet.availability_zone == aws_db_instance.mydb.availability_zone][0]
  }

  depends_on = [aws_db_instance.mydb, aws_lambda_invocation.create_rds_database_invocation]
}

resource "aws_glue_crawler" "biomirror_rds_crawler" {
  database_name = aws_glue_catalog_database.biomirror_rds_database.name
  name          = "biomirror-rds-crawler-${random_string.rand.result}"
  role          = aws_iam_role.glue-rds-role.arn

  jdbc_target {
    connection_name = aws_glue_connection.biomirror_rds_connection.name
    path            = "${var.db_name}/%"
  }

  // Start provisioner after it is created. Based on https://stackoverflow.com/questions/58034202/how-to-run-aws-glue-crawler-after-resource-update-created
  provisioner "local-exec" {
    command = "aws glue start-crawler --name ${self.name}"
  }
}

resource "aws_iam_role" "glue-rds-role" {
  name = "glue-rds-role-${random_string.rand.result}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "glue.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })

  tags = {
    Name = "Glue-RDS-Role"
  }
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRole-RDS-policy-attachment" {

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.glue-rds-role.name

}

// TODO: Add more policies here: https://awstip.com/aws-etl-insert-data-to-a-relational-database-using-glue-job-393a2e37c758


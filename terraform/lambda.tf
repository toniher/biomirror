// TODO: To be finished
// Source based on https://www.linkedin.com/pulse/como-deployar-aws-lambda-layers-com-terraform-e-nodejs-gasparoto/?trk=public_profile_article_view

// path.root here: https://www.terraform.io/language/expressions/references
locals {
  layer_name  = "mysql"
  layers_path = "${path.root}/layers/${local.layer_name}/"
  lambda_name = "create-database"
  lambda_path = "${path.root}/lambdas/${local.lambda_name}/"
  runtime     = "nodejs16.x"
}

resource "null_resource" "build_lambda_layers" {
  triggers = {
    layer_build = md5(file("${local.layers_path}/package.json"))
  }

  provisioner "local-exec" {
    working_dir = local.layers_path
    command     = "npm install --production && zip -9 -r --quiet ${local.layer_name}.zip *"
  }
}

resource "aws_lambda_layer_version" "mysql_layer" {
  filename    = "${local.layers_path}/${local.layer_name}.zip"
  layer_name  = local.layer_name
  description = "mysql layer"

  compatible_runtimes = [local.runtime]

  depends_on = [null_resource.build_lambda_layers]
}

resource "aws_iam_role" "lambda_biomirror_role" {
  name = "lambda-biomirror-${random_string.rand.result}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

// TODO: Review attached policies
resource "aws_iam_role_policy_attachment" "lambda_role_policy_RDS_attachment" {
  role       = aws_iam_role.lambda_biomirror_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_RDSData_attachment" {
  role       = aws_iam_role.lambda_biomirror_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_VPC_attachment" {
  role       = aws_iam_role.lambda_biomirror_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_VPCExec_attachment" {
  role       = aws_iam_role.lambda_biomirror_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "archive_file" "db-lambda-zip" {
  type        = "zip"

  output_path = "${local.lambda_path}/${local.lambda_name}.zip"
  source {
    content  = file("${local.lambda_path}/index.js")
    filename = "index.js"
  }
}

resource "null_resource" "add_dump" {
  provisioner "local-exec" {
    command = "zip -uj ${data.archive_file.db-lambda-zip.output_path} ${local.lambda_path}/dump.sql"
  }
}

resource "aws_lambda_function" "create_rds_database" {
  function_name = "create-db-${random_string.rand.result}"
  role          = aws_iam_role.lambda_biomirror_role.arn
  handler       = "index.handler"

  layers = [aws_lambda_layer_version.mysql_layer.arn]

  filename         = data.archive_file.db-lambda-zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.db-lambda-zip.output_path)

  runtime = local.runtime
  timeout = 60


  environment {
    variables = {
      RDS_HOSTNAME = aws_db_instance.mydb.address
      RDS_USERNAME = "root"
      RDS_PASSWORD = var.db_password
      RDS_PORT     = var.db_port
    }
  }

  depends_on = [aws_db_instance.mydb, aws_lambda_layer_version.mysql_layer, null_resource.add_dump]
}


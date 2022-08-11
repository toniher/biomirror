// TOOD: To be finished

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

resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  role       = []
  policy_arn = aws_iam_policy.stop_start_ec2_policy.arn
}

// TODO: attach this policies
// AmazonRDSFullAccess
// AmazonRDSDataFullAccess
// AmazonVPCFullAccess
// AWSLambdaVPCAccessExecutionRole

// TODO: More love needed here. Layers: https://www.linkedin.com/pulse/como-deployar-aws-lambda-layers-com-terraform-e-nodejs-gasparoto/?trk=public_profile_article_view
data "archive_file" "db-lambda-zip" {
  type        = "zip"
  source_file   = "index.js"
  output_path   = "lambda_function.zip"
  source {
    content  = "index.js"
    filename = "index.js"
  }
}

resource "aws_lambda_function" "create_rds_database" {
  filename      = data.archive_file.db-lambda-zip.output_path
  function_name = "create-db-${random_string.rand.result}"
  role          = aws_iam_role.lambda_biomirror_role.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256(data.archive_file.db-lambda-zip.output_path)

  runtime     = "nodejs16.x"
  timeout     = "60"


  environment {
    variables = {  
      RDS_HOSTNAME = aws_db_instance.mydb.address
      RDS_USERNAME = root
      RDS_PASSWORD = var.db_password
      RDS_PORT = var.db_port
    }
  }

  depends_on = [ aws_db_instance.mydb ]
}


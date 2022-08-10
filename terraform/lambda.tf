// TOOD: To be finished

resource "aws_iam_role" "lambda_biomirror_role" {
  name = "Lambda-biomirror-${random_string.rand.result}"

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

// AmazonRDSFullAccess
// AmazonRDSDataFullAccess
// AmazonVPCFullAccess
// AWSLambdaVPCAccessExecutionRole

data "archive_file" "ec2-lambda-zip" {
  type        = "zip"
  output_path = "ec2_lambda_handler.zip"
  source {
    content  = templatefile("ec2_lambda_handler.tpl", { region = var.region })
    filename = "ec2_lambda_handler.py"
  }
}

resource "aws_lambda_function" "stop_ec2_lambda" {
  filename      = data.archive_file.ec2-lambda-zip.output_path
  function_name = "stopEC2Lambda-${random_string.rand.result}"
  role          = aws_iam_role.stop_start_ec2_role.arn
  handler       = "ec2_lambda_handler.stop"

  source_code_hash = filebase64sha256(data.archive_file.ec2-lambda-zip.output_path)

  runtime     = "python3.7"
  memory_size = "250"
  timeout     = "60"
}


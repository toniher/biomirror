resource "aws_glue_catalog_database" "biomirror_s3_database" {
  name = "biomirror-s3-db-${random_string.rand.result}"
}

resource "aws_glue_classifier" "biomirror_csv" {
  name = "biomirror-csv-${random_string.rand.result}"

  csv_classifier {
    allow_single_column    = false
    contains_header        = "ABSENT"
    delimiter              = "\t"
    disable_value_trimming = false
  }
}

resource "aws_glue_crawler" "biomirror_s3_crawler" {
  database_name = aws_glue_catalog_database.biomirror_s3_database.name
  name          = "biomirror-s3-crawler-${random_string.rand.result}"
  role          = aws_iam_role.glue-s3-role.arn

  s3_target {
    path = "s3://${var.bucket_data_path}"
  }
}

resource "aws_iam_role" "glue-s3-role" {
  name = "glue-s3-role-${random_string.rand.result}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.bucket_data_path}*"
        ]
      }
    ]
  })

  tags = {
    Name = "Glue-S3-Role"
  }
}

resource "aws_iam_policy_attachment" "AWSGlueServiceRole-S3-policy-attachment" {

  name       = "AWSGlueServiceRole-S3-policy-attachment-${random_string.rand.result}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  groups     = []
  users      = []
  roles      = [aws_iam_role.glue-s3-role.name]

}
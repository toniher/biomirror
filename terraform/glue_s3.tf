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
    path = var.bucket_data_path
  }
}
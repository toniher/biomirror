resource "aws_s3_bucket" "scripts-bucket" {
  bucket        = format("%s-%s", var.bucket_scripts, random_string.rand.result)
  force_destroy = true

  tags = {
    name = format("%s-%s", var.bucket_scripts, random_string.rand.result)
  }
}

resource "aws_s3_bucket_acl" "scripts-bucket-acl" {
  bucket = aws_s3_bucket.scripts-bucket.id
  acl    = "private"
}


resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.scripts-bucket.bucket
  key    = "s3-to-rds.py"
  content = templatefile("glue_script.tpl.py", { glue_s3_db = aws_glue_catalog_database.biomirror_s3_database.name,
  glue_rds_db = aws_glue_catalog_database.biomirror_rds_database.name })

  depends_on = [aws_glue_crawler.biomirror_rds_crawler, aws_glue_crawler.biomirror_s3_crawler]

}

resource "aws_glue_job" "glue_job" {
  name              = "glue-job-${random_string.rand.result}"
  description       = "Glue Job for biomirror"
  role_arn          = aws_iam_role.glue-job-role.arn
  max_retries       = 1
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 5
  connections       = [aws_glue_connection.biomirror_rds_connection.id]

  execution_class = "STANDARD" //Alternative is FLEX

  command {
    script_location = "s3://${aws_s3_bucket.scripts-bucket.bucket}/s3-to-rds.py"
    python_version  = "3"
  }

  execution_property {
    max_concurrent_runs = 5
  }

  default_arguments = {
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-spark-ui"                  = "true"
    "--enable-glue-datacatalog"          = "true"
    "--enable-job-insights"              = "true"
    "--TempDir"                          = "s3://${aws_s3_bucket.scripts-bucket.bucket}/tmp/"
    "--spark-event-logs-path"            = "s3://${aws_s3_bucket.scripts-bucket.bucket}/logs/"
  }

  depends_on = [aws_s3_object.glue_script]
}


resource "aws_iam_role" "glue-job-role" {
  name = "glue-job-role-${random_string.rand.result}"

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
    Name = "Glue-Job-Role"
  }
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRole-Job-policy-attachment" {

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.glue-job-role.name

}

// Reference of policies here: https://awstip.com/aws-etl-insert-data-to-a-relational-database-using-glue-job-393a2e37c758

resource "aws_iam_role_policy" "glue-job-bucket-policy" {

  name = "glue-job-bucket-policy-${random_string.rand.result}"
  role = aws_iam_role.glue-job-role.id


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.scripts-bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.scripts-bucket.bucket}/*"
        ]
      }
    ]
  })

}

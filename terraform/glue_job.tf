// TODO: Change bucket about this
resource "aws_s3_object" "glue_script" {
  bucket = var.bucket_scripts
  key    = "s3-to-rds.py"
  content = templatefile("glue_script.tpl.py", { glue_s3_db = aws_glue_catalog_database.biomirror_s3_database.name,
  glue_rds_db = aws_glue_catalog_database.biomirror_rds_database.name })

}

resource "aws_glue_job" "glue_job" {
  name              = "glue-job-${random_string.rand.result}"
  description       = "Glue Job for biomirror"
  role_arn          = aws_iam_role.glue-rds-role.arn
  max_retries       = 1
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 5

  execution_class = "STANDARD" //Alternative is FLEX

  command {
    script_location = "s3://${var.bucket_scripts}/s3-to-rds.py"
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
    "--TempDir"                          = "s3://${var.bucket_scripts}/tmp/"
    "--spark-event-logs-path"            = "s3://${var.bucket_scripts}/logs/"
  }
}
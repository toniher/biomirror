Terraform recipe for setting up a RDS MariaDB database for supporting the scripts

Reference: https://citizix.com/create-an-rds-instance-in-terraform-with-a-mariadb-example/

# TODO

* Automate creation of the databases and import of schemas. Suggestion: using LAMBDA:
  * https://docs.aws.amazon.com/lambda/latest/dg/services-rds-tutorial.html
  * https://bl.ocks.org/pat/7b61376981b40cfdbb1166734b8d184f
  * https://dzone.com/articles/aws-lambda-with-mysql-rds-and-api-gateway

* Set up Glue between S3 and RDS
  * https://www.youtube.com/watch?v=rBFfYpHP1PM and  https://www.youtube.com/watch?v=f8wXc65tdAg
  * Glue crawlers in Terraform https://geeks.wego.com/creating-glue-crawlers-via-terraform/

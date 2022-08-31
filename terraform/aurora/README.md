Terraform recipe for setting up a RDS Aurora MySQL database for supporting the scripts

```
terraform plan --target=module.vpc --out=vpc.plan
terraform apply vpc.plan
terraform plan
terraform apply
```

# TODO

* Create minimum EC2 image
	* Allow S3 permission to EC2 to list target S3 bucket dir
	* User data script for importing data
* Role for S3 loading in Aurora: S3 API returned error: Both aurora_load_from_s3_role and aws_default_s3_role are not specified
  * https://pixelswap.fr/entry/how-to-load-data-from-s3-in-aurora-mysql-db-using-terraform
  * Bucket definition in data - split path and get ARN



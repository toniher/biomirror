export TF_VAR_key_name=key-nf
export TF_VAR_profile=default
export TF_VAR_credentials='["/home/myuser/.aws/credentials"]'
export TF_VAR_region=eu-central-1
export TF_VAR_vpc_id=vpc-68c6c103
export TF_VAR_route_table_id=rtb-1544fd7f
export TF_VAR_subnets='["subnet-8a280df7", "subnet-c54d6588", "subnet-b85ab5d2"]'
# DB stuff
export TF_VAR_db_cidr_blocks='["172.0.0.0/8"]'
export TF_VAR_db_engine=mariadb
export TF_VAR_db_instance=db.t3.xlarge
export TF_VAR_db_password=3this1.passwd
export TF_VAR_db_storage=250
export TF_VAR_db_max_storage=1000
export TF_VAR_db_port=3306
export TF_VAR_db_name=biomirror

#Bucket
export TF_VAR_bucket_data_path=mybucket/output/data.gz
export TF_VAR_bucket_scripts=mybucket

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity|jq .Account|tr -d \")

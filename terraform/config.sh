export TF_VAR_key_name=key-nf
export TF_VAR_profile=default
export TF_VAR_credentials='["/home/myuser/.aws/credentials"]'
export TF_VAR_region=eu-central-1
export TF_VAR_vpc_id=vpc-68c6c103
export TF_VAR_subnets='["subnet-8a280df7", "subnet-c54d6588", "subnet-b85ab5d2"]'
# DB stuff
export TF_VAR_db_engine=mariadb
export TF_VAR_db_instance=db.t3.medium
export TF_VAR_db_password=3this1.passwd
export TF_VAR_db_storage=250
export TF_VAR_db_max_storage=1000
export TF_VAR_db_port=3306

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity|jq .Account|tr -d \")

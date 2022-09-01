export TF_VAR_key_name=key-nf
export TF_VAR_profile=default
export TF_VAR_ec2_ami=ami-0872ea47efc1cee46
export TF_VAR_ec2_instance_type=t2.micro
export TF_VAR_credentials='["/home/myuser/.aws/credentials"]'
export TF_VAR_region=eu-central-1
export TF_VAR_availability_zones='["eu-central-1a", "eu-central-1b", "eu-central-1c"]'
export TF_VAR_cidr="172.35.0.0/16"
export TF_var_public_subnets='["172.35.3.0/24", "172.35.4.0/24", "172.35.5.0/24"]'
# DB stuff
export TF_VAR_db_engine=aurora-mysql
export TF_VAR_db_instance=db.t3.large
export TF_VAR_db_password=3this1.passwd
export TF_VAR_db_storage=250
export TF_VAR_db_max_storage=1000
export TF_VAR_db_port=3306
export TF_VAR_db_name=biomirror

#Bucket
export TF_VAR_bucket_data_path=mybucket/output/data.gz

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity|jq .Account|tr -d \")

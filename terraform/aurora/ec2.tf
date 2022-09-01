// You may define an entry point for convenience

resource "aws_instance" "ec2_executor" {

    ami                  = var.ec2_ami
    instance_type        = var.ec2_instance_type
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    key_name             = var.key_name
    security_groups      = []
    user_data            = templatefile("ec2init.sh.tpl", { db_passwd = var.db_password, db_host = aws_rds_cluster.aurora_cluster.endpoint, s3_data=var.bucket_data_path, rand = random_string.rand.result })
    root_block_device {
        volume_size = var.ec2_volume_size
    }


    // Let's wait all buckets to be created first. It could be even tried one by one
    depends_on = [aws_lambda_function.create_rds_database, aws_iam_instance_profile.ec2_profile]

    tags = {
        name = "ec2-executor-${random_string.rand.result}"
    }

}


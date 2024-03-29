// You may define an entry point for convenience

resource "aws_instance" "ec2_executor" {

  ami                    = var.ec2_ami
  instance_type          = var.ec2_instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  user_data              = templatefile("ec2init.sh.tpl", { db_password = var.db_password, db_host = aws_rds_cluster.aurora_cluster.endpoint, bucket_data_path = var.bucket_data_path, rand = random_string.rand.result })
  root_block_device {
    volume_size = var.ec2_volume_size
  }

  subnet_id = module.vpc.public_subnets[0] // Let's get the first subnet

  // Let's wait all buckets to be created first. It could be even tried one by one
  depends_on = [aws_lambda_invocation.create_rds_database_invocation, aws_rds_cluster_parameter_group.mydb, aws_iam_instance_profile.ec2_profile]

  tags = {
    name = "ec2-executor-${random_string.rand.result}"
  }

}

// Role for the entrypoint
resource "aws_iam_role" "ec2_access" {
  name = "ec2-access-${random_string.rand.result}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile-${random_string.rand.result}"
  role = aws_iam_role.ec2_access.name
}

resource "aws_iam_policy_attachment" "AmazonEC2FullAccess-policy-attachment" {

  name       = "AmazonEC2FullAccess-policy-attachment-${random_string.rand.result}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  groups     = []
  users      = []
  roles      = [aws_iam_role.ec2_access.name]
}

resource "aws_iam_role_policy" "my-s3-read-policy" {
  name   = "ec2-access-s3-role-policy-${random_string.rand.result}"
  role   = aws_iam_role.ec2_access.id
  policy = data.aws_iam_policy_document.s3_read_permissions.json
}

data "aws_iam_policy_document" "s3_read_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:ListBucket",
    ]

    resources = ["arn:aws:s3:::${data.aws_s3_bucket.bucket_data.id}",
      "arn:aws:s3:::${data.aws_s3_bucket.bucket_data.id}/*",
    ]
  }

  depends_on = [data.aws_s3_bucket.bucket_data]

}

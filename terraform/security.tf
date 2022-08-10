resource "aws_security_group" "allow_mariadb" {
    name = "prod-mariadb-rds-sg"
    description = "Allow TLS inbound traffic"
    vpc_id = data.aws_vpc.my_vpc.id

    ingress {
        description = "Mariadb Access from within the VPC"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/8"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Allow access to prod mariadb rds"
    }
}

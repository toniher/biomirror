resource "aws_security_group" "allow_db" {
  name        = "db-rds-sg-${random_string.rand.result}"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Access from within the VPC"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.db_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow access to prod rds"
  }
}

resource "aws_security_group" "allow_db_glue" {
  name        = "db-rds-glue-sg-${random_string.rand.result}"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Access from within the VPC"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.db_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow access to prod rds"
  }
}

// This allows self-referencing
resource "aws_security_group_rule" "sec_group_glue_self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.allow_db_glue.id
  source_security_group_id = aws_security_group.allow_db_glue.id
}

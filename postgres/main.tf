data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket         = "automotors-s3"
    key            = "automotors-terraform/infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }
}

resource "aws_db_subnet_group" "db" {
  name       = "${var.project}-${var.env}-db-subnets"
  subnet_ids = data.terraform_remote_state.infra.outputs.private_subnets
  tags = { Name = "${var.project}-${var.env}-db-subnets" }
}

resource "aws_security_group" "db_sg" {
  name   = "${var.project}-${var.env}-db-sg"
  vpc_id = data.terraform_remote_state.infra.outputs.vpc_id

  ingress {
    description              = "Allow postgres from EKS nodes"
    from_port                = 5432
    to_port                  = 5432
    protocol                 = "tcp"
    security_groups          = [data.terraform_remote_state.infra.outputs.node_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.project
    Env     = var.env
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.project}-${var.env}-postgres"
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20

  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  port                   = 5432

  storage_encrypted      = true
  skip_final_snapshot    = true
  publicly_accessible    = false

  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db.name

  tags = {
    Project = var.project
    Env     = var.env
  }
}


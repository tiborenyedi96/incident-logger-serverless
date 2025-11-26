resource "aws_rds_cluster" "this" {
  cluster_identifier      = "${var.name}-rds-cluster"
  engine                  = "aurora-mysql"
  engine_mode             = "provisioned"
  database_name           = "incident_logger_db"
  master_username         = var.db_username
  master_password         = random_password.rds_password.result
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  storage_encrypted       = true
  backup_retention_period = 5
  apply_immediately       = true
  skip_final_snapshot     = true

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 2
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  availability_zone   = "eu-central-1a"
  publicly_accessible = false
  identifier          = "${var.name}-rds-cluster-instance"
  cluster_identifier  = aws_rds_cluster.this.id
  instance_class      = "db.serverless"
  engine              = "aurora-mysql"
}

resource "aws_secretsmanager_secret" "rds_secret" {
  name = "${var.name}-rds-secret"
}

resource "random_password" "rds_password" {
  length  = 32
  special = true
}

resource "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.rds_password.result
  })
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.name}-rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name    = "${var.name}-rds-subnet-group"
    Project = var.name
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "${var.name}-rds-sg"
  vpc_id = var.vpc_id

  tags = {
    Name    = "${var.name}-rds-sg"
    Project = var.name
  }
}
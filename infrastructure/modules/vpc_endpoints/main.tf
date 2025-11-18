resource "aws_security_group" "vpce_sg" {
  name        = "${var.name}-vpce-sg"
  description = "Allow Lambda to access VPC interface endpoints"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-vpce-sg"
    Project = var.name
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.subnet_ids
  security_group_ids = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.name}-secretsmanager-endpoint"
    Project = var.name
  }
}
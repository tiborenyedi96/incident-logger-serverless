resource "aws_vpc" "this"{
    cidr_block = var.cidr_block
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = var.name
        Project = "incident-logger"
    }
}

resource "aws_subnet" "private_a" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.private_a
  availability_zone = "eu-central-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}-private-a"
    Project = "incident-logger"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.private_b
  availability_zone = "eu-central-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}-private-b"
    Project = "incident-logger"
  }
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-private-rtb"
    Project = "incident-logger"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rtb.id
}
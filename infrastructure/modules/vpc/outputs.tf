output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_a_subnet_id" {
  value = aws_subnet.private_a.id
}

output "private_b_subnet_id" {
  value = aws_subnet.private_b.id
}

output "private_rtb_id" {
  value = aws_route_table.private_rtb.id
}
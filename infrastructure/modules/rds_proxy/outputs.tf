output "rds_proxy_arn" {
  value = aws_db_proxy.this.arn
}

output "rds_proxy_endpoint" {
  value = aws_db_proxy.this.endpoint
}

output "rds_proxy_security_group_id" {
  value = aws_security_group.rds_proxy_sg.id
}

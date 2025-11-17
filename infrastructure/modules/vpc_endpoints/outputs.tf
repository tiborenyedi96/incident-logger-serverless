output "vpce_security_group_id" {
  description = "Security group ID attached to VPC endpoints"
  value       = aws_security_group.vpce_sg.id
}

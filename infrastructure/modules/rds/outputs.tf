output "rds_cluster_arn" {
  value = aws_rds_cluster.this.arn
}

output "rds_cluster_identifier" {
  value = aws_rds_cluster.this.cluster_identifier
}

output "rds_secretsmanager_secret_arn" {
  value = aws_secretsmanager_secret.rds_secret.arn
}
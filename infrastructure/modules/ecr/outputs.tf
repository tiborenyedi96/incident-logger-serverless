output "get_repository_url" {
  description = "URL of the GET Lambda ECR repository"
  value       = aws_ecr_repository.get_repository.repository_url
}

output "post_repository_url" {
  description = "URL of the POST Lambda ECR repository"
  value       = aws_ecr_repository.post_repository.repository_url
}
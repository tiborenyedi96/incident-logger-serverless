resource "aws_ecr_repository" "this" {
  name                 = "${var.name}-lambda-image-repository"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}
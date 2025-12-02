resource "aws_ecr_repository" "get_repository" {
  name                 = "${var.name}-lambda-get-image-repository"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_repository" "post_repository" {
  name                 = "${var.name}-lambda-post-image-repository"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}
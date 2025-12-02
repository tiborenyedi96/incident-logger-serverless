resource "aws_ecr_repository" "get_repository" {
  name                 = "${var.name}-lambda-get-image-repository"
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  image_tag_mutability_exclusion_filter {
    filter      = "latest*"
    filter_type = "WILDCARD"
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_repository" "post_repository" {
  name                 = "${var.name}-lambda-post-image-repository"
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  image_tag_mutability_exclusion_filter {
    filter      = "latest*"
    filter_type = "WILDCARD"
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}
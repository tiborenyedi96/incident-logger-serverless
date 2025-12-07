data "aws_region" "current" {}

data "aws_arn" "rds_proxy" {
  arn = var.rds_proxy_arn
}

locals {
  proxy_resource_id = split(":", data.aws_arn.rds_proxy.resource)[1]
}

resource "aws_security_group" "lambda_sg" {
  name   = "${var.name}-lambda-sg"
  vpc_id = var.vpc_id
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_rds_policy" {
  name        = "${var.name}-lambda-policy"
  description = "Lambda policy for RDS proxy"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : "rds-db:connect",
        Resource : "arn:aws:rds-db:${data.aws_region.current.id}:${data.aws_arn.rds_proxy.account}:dbuser:${local.proxy_resource_id}/${var.db_username}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_rds_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_execution_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_ecr_read_only" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

//GET function
resource "aws_lambda_function" "lambda_get_incidents" {
  package_type  = "Image"
  image_uri     = "${var.get_repository_url}:latest"
  function_name = "${var.name}-lambda-get-incidents"
  role          = aws_iam_role.lambda_role.arn
  memory_size   = var.function_memory
  timeout       = var.function_timeout
  architectures = ["arm64"]

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_PROXY_ENDPOINT = var.rds_proxy_endpoint
      DB_USER           = var.db_username
    }
  }
}

//POST function
resource "aws_lambda_function" "lambda_post_incident" {
  package_type  = "Image"
  image_uri     = "${var.post_repository_url}:latest"
  function_name = "${var.name}-lambda-post-incident"
  role          = aws_iam_role.lambda_role.arn
  memory_size   = var.function_memory
  timeout       = var.function_timeout
  architectures = ["arm64"]

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_PROXY_ENDPOINT = var.rds_proxy_endpoint
      DB_USER           = var.db_username
    }
  }
}
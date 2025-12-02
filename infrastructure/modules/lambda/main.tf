resource "aws_security_group" "lambda_sg" {
  name   = "${var.name}-lambda-sg"
  vpc_id = var.vpc_id

  tags = {
    Name    = "${var.name}-lambda-sg"
    Project = var.name
  }
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

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.name}-lambda-policy"
  description = "Lambda policy for Secrets Manager and RDS proxy"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : "rds-db:connect",
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

//GET function
resource "aws_lambda_function" "lambda_get_incidents" {
  filename      = "${path.module}/get-function.zip"
  function_name = "${var.name}-lambda-get-incidents"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.12"
  memory_size   = var.function_memory
  timeout       = var.function_timeout

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

  tags = {
    Name    = "${var.name}-lambda-get-incidents"
    Project = var.name
  }
}

//POST function
resource "aws_lambda_function" "lambda_post_incident" {
  filename      = "${path.module}/post-function.zip"
  function_name = "${var.name}-lambda-post-incident"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.12"
  memory_size   = var.function_memory
  timeout       = var.function_timeout

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

  tags = {
    Name    = "${var.name}-lambda-post-incidents"
    Project = var.name
  }
}
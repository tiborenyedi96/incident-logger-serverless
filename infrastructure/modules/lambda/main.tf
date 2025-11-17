resource "aws_security_group" "lambda_sg" {
  name        = "${var.name}-lambda-sg"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-lambda-sg"
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
  description = "Lambda policy for Secrets Manager, RDS Proxy, and Logs"

  policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect   = "Allow"
      Action   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    },
    {
      Effect   = "Allow"
      Action   = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = var.rds_secretsmanager_secret_arn
    },
    {
      Effect   = "Allow"
      Action   = ["kms:Decrypt"]
      Resource = "*"
    },
    {
      Effect = "Allow"
      Action = [
        "rds-db:connect"
      ]
      Resource = "*"
    },
    {
      Effect = "Allow"
      Action = [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:AssignPrivateIpAddresses",
        "ec2:UnassignPrivateIpAddresses",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ]
      Resource = "*"
    }
  ]
})
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_lambda_function" "lambda_get_incidents" {
    filename      = "${path.module}/get-function.zip"
    function_name = "${var.name}-lambda-get-incidents"
    role          = aws_iam_role.lambda_role.arn
    handler       = "index.lambda_handler"
    runtime       = "python3.12"
    memory_size   = 512
    timeout       = 30

  vpc_config {
    subnet_ids                  = var.subnet_ids
    security_group_ids          = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      SECRET_ARN        = var.rds_secretsmanager_secret_arn
      DB_PROXY_ENDPOINT = var.rds_proxy_endpoint
    }
  }

  tags = {
  Name = "${var.name}-lambda-get-incidents"
  Project = var.name
  }
}

resource "aws_lambda_function" "lambda_post_incident" {
    filename      = "${path.module}/post-function.zip"
    function_name = "${var.name}-lambda-post-incident"
    role          = aws_iam_role.lambda_role.arn
    handler       = "index.lambda_handler"
    runtime       = "python3.12"
    memory_size   = 512
    timeout       = 30

  vpc_config {
    subnet_ids                  = var.subnet_ids
    security_group_ids          = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      SECRET_ARN        = var.rds_secretsmanager_secret_arn
      DB_PROXY_ENDPOINT = var.rds_proxy_endpoint
    }
  }
  
  tags = {
  Name = "${var.name}-lambda-get-incidents"
  Project = var.name
  }
}
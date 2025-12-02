resource "aws_iam_openid_connect_provider" "github_actions_oidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}

#Github actions role and policy for infra planning pipeline

resource "aws_iam_role" "github_actions_terraform_infra_plan_role" {
  name = "${var.name}-github-actions-terraform-infra-plan-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:sub" = "repo:tiborenyedi96/incident-logger-serverless:pull_request",
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_terraform_infra_plan_policy" {
  name        = "${var.name}-github-actions-terraform-infra-plan-policy"
  description = "Terraform infra plan policy for GitHub Actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "TFStateS3Access",
        Effect : "Allow",
        Action : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource : [
          "arn:aws:s3:::incident-logger-tf-state",
          "arn:aws:s3:::incident-logger-tf-state/*"
        ]
      },
      {
        Sid : "FrontendBucketMetadata",
        Effect : "Allow",
        Action : [
          "s3:Get*",
          "s3:List*"
        ],
        Resource : "arn:aws:s3:::incident-logger-frontend"
      },
      {
        Sid : "TFStateDynamoDBLockAccess",
        Effect : "Allow",
        Action : [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ],
        Resource : "arn:aws:dynamodb:eu-central-1:299097238534:table/incident-logger-tf-lock"
      },
      {
        Sid : "ReadOnlyForPlan",
        Effect : "Allow",
        Action : [
          "ec2:Describe*",
          "rds:Describe*",
          "rds:ListTagsForResource",
          "iam:Get*",
          "iam:List*",
          "lambda:Get*",
          "lambda:List*",
          "elasticloadbalancing:Describe*",
          "apigateway:GET",
          "secretsmanager:GetSecretValue",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:ListSecrets",
          "secretsmanager:DescribeSecret",
          "s3:ListAllMyBuckets",
          "cloudfront:Get*",
          "cloudfront:List*",
          "ecr:Describe*",
          "ecr:Get*",
          "ecr:List*",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform_infra_plan_policy_attachment" {
  role       = aws_iam_role.github_actions_terraform_infra_plan_role.name
  policy_arn = aws_iam_policy.github_actions_terraform_infra_plan_policy.arn
}

#Github actions role and policy for infra applying pipeline

resource "aws_iam_role" "github_actions_terraform_infra_apply_role" {
  name = "${var.name}-github-actions-terraform-infra-apply-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:sub" = "repo:tiborenyedi96/incident-logger-serverless:ref:refs/heads/main",
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_terraform_infra_apply_policy" {
  name        = "${var.name}-github-actions-terraform-infra-apply-policy"
  description = "Terraform infra apply policy for GitHub Actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "TFStateS3Access",
        Effect : "Allow",
        Action : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource : [
          "arn:aws:s3:::incident-logger-tf-state",
          "arn:aws:s3:::incident-logger-tf-state/*"
        ]
      },
      {
        Sid : "TFStateDynamoDBLockAccess",
        Effect : "Allow",
        Action : [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
          "dynamodb:DescribeTable"
        ],
        Resource : "arn:aws:dynamodb:eu-central-1:299097238534:table/incident-logger-tf-lock"
      },
      {
        Sid : "S3CRUD",
        Effect : "Allow",
        Action : [
          "s3:*"
        ],
        Resource : "*"
      },
      {
        Sid : "LambdaCRUD",
        Effect : "Allow",
        Action : [
          "lambda:*"
        ],
        Resource : "*"
      },
      {
        Sid : "APIGatewayCRUD",
        Effect : "Allow",
        Action : [
          "apigateway:*"
        ],
        Resource : "*"
      },
      {
        Sid : "IAMCRUD",
        Effect : "Allow",
        Action : [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:UpdateRole",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:Get*",
          "iam:List*"
        ],
        Resource : "*"
      },
      {
        Sid : "CloudFrontCRUD",
        Effect : "Allow",
        Action : [
          "cloudfront:*"
        ],
        Resource : "*"
      },
      {
        Sid : "DynamoDBCRUD",
        Effect : "Allow",
        Action : [
          "dynamodb:*"
        ],
        Resource : "*"
      },
      {
        Sid : "EC2CRUD",
        Effect : "Allow",
        Action : [
          "ec2:*"
        ],
        Resource : "*"
      },
      {
        Sid : "RDSCRUD",
        Effect : "Allow",
        Action : [
          "rds:*"
        ],
        Resource : "*"
      },
      {
        Sid : "SecretsManagerCRUD",
        Effect : "Allow",
        Action : [
          "secretsmanager:*"
        ],
        Resource : "*"
      },
      {
        Sid : "ECRCRUD",
        Effect : "Allow",
        Action : [
          "ecr:*"
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform_infra_apply_policy_attachment" {
  role       = aws_iam_role.github_actions_terraform_infra_apply_role.name
  policy_arn = aws_iam_policy.github_actions_terraform_infra_apply_policy.arn
}

#Github actions role and policy for building and pushing frontend changes to S3

resource "aws_iam_role" "github_actions_frontend_build_role" {
  name = "${var.name}-github-actions-frontend-build-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:sub" = "repo:tiborenyedi96/incident-logger-serverless:ref:refs/heads/main",
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_frontend_build_policy" {
  name        = "${var.name}-github-actions-frontend-build-policy"
  description = "Frontend build/push policy for GitHub Actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "ActionsBucketAccess",
        Effect : "Allow",
        Action : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource : [
          "arn:aws:s3:::incident-logger-frontend",
          "arn:aws:s3:::incident-logger-frontend/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_frontend_build_policy_attachment" {
  role       = aws_iam_role.github_actions_frontend_build_role.name
  policy_arn = aws_iam_policy.github_actions_frontend_build_policy.arn
}

#Github actions role and policy for building and pushing lambda containers to ECR

resource "aws_iam_role" "github_actions_ecr_role" {
  name = "${var.name}-github-actions-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:sub" = "repo:tiborenyedi96/incident-logger-serverless:ref:refs/heads/main",
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# resource "aws_iam_policy" "github_actions_ecr_policy" {
#   name        = "${var.name}-github-actions-ecr-policy"
#   description = "Policy for GitHub Actions to push to ECR and update Lambda functions"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "ecr:GetAuthorizationToken"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:PutImage",
#           "ecr:InitiateLayerUpload",
#           "ecr:UploadLayerPart",
#           "ecr:CompleteLayerUpload",
#           "ecr:BatchGetImage",
#           "ecr:DescribeImages",
#           "ecr:DescribeRepositories"
#         ],
#         Resource = "arn:aws:ecr:eu-central-1:299097238534:repository/incident-logger-*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "lambda:UpdateFunctionCode",
#           "lambda:GetFunction"
#         ],
#         Resource = "arn:aws:lambda:eu-central-1:299097238534:function:incident-logger-*"
#       }
#     ]
#   })
# }

resource "aws_iam_role_policy_attachment" "lambda_ecr_read_only" {
  role       = aws_iam_role.github_actions_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# resource "aws_iam_role_policy_attachment" "github_actions_ecr_policy_attachment" {
#   role       = aws_iam_role.github_actions_ecr_role.name
#   policy_arn = aws_iam_policy.github_actions_ecr_policy.arn
# }
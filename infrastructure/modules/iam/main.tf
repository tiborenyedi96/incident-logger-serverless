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
          "s3:DeleteObject",
          "s3:ListBucket"
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
          "apigatewayv2:Get*",
          "apigatewayv2:List*",
          "secretsmanager:GetSecretValue",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:ListSecrets",
          "secretsmanager:DescribeSecret",
          "s3:ListAllMyBuckets",
          "cloudfront:Get*",
          "cloudfront:List*"
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
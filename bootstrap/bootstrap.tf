terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "AdministratorAccess-299097238534"
}

resource "aws_s3_bucket" "tf_state" {
  bucket        = "incident-logger-tf-state"
  force_destroy = false
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "incident-logger-tf-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
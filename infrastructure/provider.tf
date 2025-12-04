provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Project     = "incident-logger"
      Environment = "production"
      ManagedBy   = "Terraform"
    }
  }
}

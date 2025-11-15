terraform {
  backend "s3" {
    bucket       = "incident-logger-tf-state"
    key          = "global/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
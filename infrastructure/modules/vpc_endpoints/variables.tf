variable "name" {
  type        = string
}

variable "vpc_id" {
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
}

variable "aws_region" {
  type        = string
}

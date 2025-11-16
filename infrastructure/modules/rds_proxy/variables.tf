variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "rds_cluster_arn" {
  type = string
}

variable "rds_cluster_identifier" {
  type = string
}

variable "rds_secretsmanager_secret_arn" {
  type = string
}
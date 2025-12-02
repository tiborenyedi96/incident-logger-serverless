variable "name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "rds_proxy_endpoint" {
  type = string
}

variable "function_memory" {
  type = number
}

variable "function_timeout" {
  type = number
}
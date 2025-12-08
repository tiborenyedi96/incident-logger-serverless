variable "alarm_email" {
  type      = string
  sensitive = true
}

variable "lambda_get_function_name" {
  type = string
}

variable "lambda_post_function_name" {
  type = string
}

variable "api_gateway_id" {
  type = string
}

variable "rds_cluster_identifier" {
  type = string
}
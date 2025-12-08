variable "alarm_email" {
  type      = string
  sensitive = true
}

variable "lambda_get_function_name" {
  type        = string
  description = "Name of the GET Lambda function"
  default     = "incident-logger-lambda-get-incidents"
}

variable "lambda_post_function_name" {
  type        = string
  description = "Name of the POST Lambda function"
  default     = "incident-logger-lambda-post-incident"
}

variable "api_gateway_name" {
  type        = string
  description = "Name of the API Gateway"
  default     = "incident-logger-API-GW"
}

variable "rds_cluster_identifier" {
  type        = string
  description = "RDS cluster identifier"
  default     = "incident-logger-rds-cluster"
}
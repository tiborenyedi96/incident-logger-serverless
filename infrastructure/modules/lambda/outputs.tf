output "lambda_security_group_id" {
  value = aws_security_group.lambda_sg.id
}

output "get_function_invoke_arn" {
  value = aws_lambda_function.lambda_get_incidents.invoke_arn
}

output "post_function_invoke_arn" {
  value = aws_lambda_function.lambda_post_incident.invoke_arn
}

output "get_function_arn" {
  value = aws_lambda_function.lambda_get_incidents.arn
}

output "post_function_arn" {
  value = aws_lambda_function.lambda_post_incident.arn
}
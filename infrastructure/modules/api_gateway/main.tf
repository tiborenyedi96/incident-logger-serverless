resource "aws_apigatewayv2_api" "this" {
  name          = "${var.name}-API-GW"
  protocol_type = "HTTP"
  body          = file("${path.module}/openapi-definition.yaml")

  cors_configuration {
    allow_methods = ["POST", "GET", "OPTIONS"]
    allow_headers = ["content-type"]
    allow_origins = [var.cloudfront_domain]
    max_age       = 3600
  }
}

resource "aws_lambda_permission" "allow_apigw_get" {
  statement_id  = "AllowAPIInvokeGET"
  action        = "lambda:InvokeFunction"
  function_name = var.get_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigw_post" {
  statement_id  = "AllowAPIInvokePOST"
  action        = "lambda:InvokeFunction"
  function_name = var.post_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}
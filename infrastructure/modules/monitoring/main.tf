resource "aws_cloudwatch_dashboard" "lambda_dashboard" {
  dashboard_name = "incident-logger-lambda-dashboard"
  dashboard_body = templatefile("${path.module}/lambda-dashboard.tpl.json", {})
}

resource "aws_cloudwatch_dashboard" "rds_proxy_dashboard" {
  dashboard_name = "incident-logger-rds-proxy-dashboard"
  dashboard_body = templatefile("${path.module}/rdsproxy-dashboard.tpl.json", {})
}

resource "aws_cloudwatch_dashboard" "rds_dashboard" {
  dashboard_name = "incident-logger-rds-dashboard"
  dashboard_body = templatefile("${path.module}/rds-dashboard.tpl.json", {})
}

resource "aws_cloudwatch_dashboard" "apigw_dashboard" {
  dashboard_name = "incident-logger-apigw-dashboard"
  dashboard_body = templatefile("${path.module}/apigw-dashboard.tpl.json", {})
}
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "incident-logger-lambda-dashboard"

  dashboard_body = templatefile("${path.module}/lambda-dashboard.tpl.json", {

  })
}
# SNS topic for alarm notifications

resource "aws_sns_topic" "alarm_notifications" {
  name         = "cloudwatch-alarm-notifications"
  display_name = "Cloudwatch Alarm Notifications"
}

resource "aws_sns_topic_subscription" "alarm_notifications_subscription" {
  topic_arn = aws_sns_topic.alarm_notifications.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# cloudwatch dashboards

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
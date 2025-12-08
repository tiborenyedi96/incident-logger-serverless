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

# Lambda alarms for function errors
resource "aws_cloudwatch_metric_alarm" "lambda_get_errors" {
  alarm_name          = "lambda-get-incidents-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    FunctionName = var.lambda_get_function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_post_errors" {
  alarm_name          = "lambda-post-incident-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    FunctionName = var.lambda_post_function_name
  }
}

# API Gateway 5xx errors (system failures)
resource "aws_cloudwatch_metric_alarm" "apigw_5xx_errors" {
  alarm_name          = "api-gateway-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xx"
  namespace           = "AWS/ApiGatewayV2"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    ApiId = var.api_gateway_id
  }
}

# RDS alarms
resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization" {
  alarm_name          = "rds-high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    DBClusterIdentifier = var.rds_cluster_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_serverless_capacity" {
  alarm_name          = "rds-serverless-capacity-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "ServerlessDatabaseCapacity"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 1.5
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    DBClusterIdentifier = var.rds_cluster_identifier
  }
}
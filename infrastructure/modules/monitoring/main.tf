resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "my-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 12

        properties = {
          metrics = [
            [
              "AWS/Lambda",
              "Errors",
              "FunctionName",
              "incident-logger-lambda-get-incidents"
            ]
          ]
          period = 300
          stat   = "Average"
          region = "eu-central-1"
          title  = "Lambda GET errors"
        }
      }
    ]
  })
}
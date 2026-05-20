resource "aws_cloudwatch_log_group" "application" {
  name              = "/starttech/application"
  retention_in_days = 14
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "starttech-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80

  alarm_description = "Alarm when CPU exceeds 80%"
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "starttech-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization"]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "EC2 CPU Utilization"
        }
      }
    ]
  })
}
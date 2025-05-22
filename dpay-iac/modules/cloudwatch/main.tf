resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.name_prefix}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "High CPU detected"
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
  alarm_actions = []
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.name_prefix}-high-mem"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "High memory usage detected"
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
  alarm_actions = []
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  alarm_name          = "${var.name_prefix}-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Instance status check failed"
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
  alarm_actions = []
}

resource "aws_cloudwatch_metric_alarm" "network_in" {
  alarm_name          = "${var.name_prefix}-high-network-in"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 10000000 # 10 MB
  alarm_description   = "High network in traffic"
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
  alarm_actions = []
}

resource "aws_cloudwatch_metric_alarm" "network_out" {
  alarm_name          = "${var.name_prefix}-high-network-out"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 10000000 # 10 MB
  alarm_description   = "High network out traffic"
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
  alarm_actions = []
}

resource "aws_cloudwatch_dashboard" "asg_dashboard" {
  dashboard_name = "${var.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x = 0
        y = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name, { stat: "Average" } ]
          ]
          period = 60
          stat = "Average"
          region = "${data.aws_region.current.name}"
          title = "CPU Utilization"
          view = "timeSeries"
          stacked = false
        }
      },
      {
        type = "metric"
        x = 12
        y = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            [ "CWAgent", "mem_used_percent", "AutoScalingGroupName", var.asg_name, { stat: "Average" } ]
          ]
          period = 60
          stat = "Average"
          region = "${data.aws_region.current.name}"
          title = "Memory Usage (%)"
          view = "timeSeries"
          stacked = false
        }
      },
      {
        type = "metric"
        x = 0
        y = 6
        width = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/EC2", "StatusCheckFailed", "AutoScalingGroupName", var.asg_name, { stat: "Maximum" } ]
          ]
          period = 60
          stat = "Maximum"
          region = "${data.aws_region.current.name}"
          title = "Status Check Failures"
          view = "timeSeries"
          stacked = false
        }
      },
      {
        type = "metric"
        x = 12
        y = 6
        width = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/EC2", "NetworkIn", "AutoScalingGroupName", var.asg_name, { stat: "Average" } ],
            [ ".", "NetworkOut", ".", ".", { stat: "Average" } ]
          ]
          period = 60
          stat = "Average"
          region = "${data.aws_region.current.name}"
          title = "Network Traffic (In / Out)"
          view = "timeSeries"
          stacked = false
        }
      }
    ]
  })
}

data "aws_region" "current" {}

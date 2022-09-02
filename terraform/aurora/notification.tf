// Notification. Reference: https://adamtheautomator.com/terraform-cloudwatch/

variable "email" {
    type    = string
}

resource "aws_sns_topic" "biomirror-done-topic" {
    name            = "biomirror-done-topic"
    delivery_policy = jsonencode({
    "http" : {
        "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 20,
        "maxDelayTarget" : 20,
        "numRetries" : 3,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
        },
        "disableSubscriptionOverrides" : false,
        "defaultThrottlePolicy" : {
        "maxReceivesPerSecond" : 1
        }
    }
    })
}

resource "aws_sns_topic_subscription" "biomirror-done-topic_subscription" {
    topic_arn = aws_sns_topic.biomirror-done-topic.arn
    protocol  = "email"
    endpoint  = var.email

    depends_on = [ aws_sns_topic.biomirror-done-topic ]
}

resource "aws_cloudwatch_metric_alarm" "executor_check" {
    
    alarm_name          = "Instance-check-on-biomirror"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "StatusCheckFailed"
    namespace           = "AWS/EC2"
    period              = "300"
    statistic           = "Maximum"
    threshold           = "1.0"
    alarm_description   = "EC2 Executor Check"
    alarm_actions       = [aws_sns_topic.biomirror-done-topic.arn]
    dimensions          = {
        InstanceId = aws_instance.ec2_executor.id
    }

    depends_on = [ aws_instance.ec2_executor ]
}
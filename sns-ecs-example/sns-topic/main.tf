# create a role ARN for cloudwatch logs
resource "aws_iam_role" "cloudwatch_logs_role" {
  name = "SNSFailureFeedback-${var.env_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "SNSFailureFeedback-${var.env_name}"
  description = "Policy for SNS to send failure logs to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:PutMetricFilter",
          "logs:PutRetentionPolicy"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.cloudwatch_logs_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

resource "aws_sns_topic" "this" {
  name = "hatchet-${var.env_name}-sns-topic"

  http_failure_feedback_role_arn = aws_iam_role.cloudwatch_logs_role.arn

  tags = {
    Environment = var.env_name
    Terraform   = "true"
  }
}

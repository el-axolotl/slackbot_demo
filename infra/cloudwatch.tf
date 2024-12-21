resource "aws_cloudwatch_log_group" "lambda_cloudwatch_logs" {
  name              = "${var.name}-${var.env}-${var.region}-lambda_logs"
  retention_in_days = var.cloudwatch_log_retention_in_days
}
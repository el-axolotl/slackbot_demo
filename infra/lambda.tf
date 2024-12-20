data "archive_file" "code" {
  output_path = "${path.module}/../src/lambda_function_payload.zip"
  source_file = "${path.module}/../src/main.py"
  type        = "zip"
}

resource "aws_lambda_function" "lambda_function" {
  filename         = "${path.module}/../src/lambda_function_payload.zip"
  function_name    = "${var.name}-${var.env}-${var.region}-lambda_function"
  handler          = "main.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.12"
  source_code_hash = data.archive_file.code.output_base64sha256

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    aws_cloudwatch_log_group.lambda_cloudwatch_logs
  ]
}
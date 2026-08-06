output "slack_request_url" {
  description = "The full API Gateway URL to use as the Slack slash command Request URL."
  value = "${aws_apigatewayv2_stage.lambda_stage.invoke_url}/${var.name}"
}

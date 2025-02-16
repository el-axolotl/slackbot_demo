resource "aws_apigatewayv2_api" "api_gateway" {
  description = "The API Gateway used to execute the lambda function."

  name          = "${var.name}-${var.env}-${var.region}-api_gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda_stage" {
  description = "The API Gateway environment, referred to as a stage."

  api_id      = aws_apigatewayv2_api.api_gateway.id
  auto_deploy = true
  name        = var.env

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.lambda_cloudwatch_logs.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })

  }

}

resource "aws_apigatewayv2_integration" "api_gateway_integration" {
  description = "Ties the API Gateway to the lambda function."

  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_uri    = aws_lambda_function.lambda_function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_gateway_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "GET /${var.name}"
  target    = "integrations/${aws_apigatewayv2_integration.api_gateway_integration.id}"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}

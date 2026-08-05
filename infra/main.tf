provider "aws" {
  region = var.region

  default_tags {
    tags = {
      app         = "slackbot_demo",
      environment = var.env
    }
  }

}

# ---------------------------------------------------------------------------
# IAM - start
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    resources = ["arn:aws:logs:*"] #TODO: Provide cloudwatch arn

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

resource "aws_iam_role" "lambda_role" {
  description = "The iam role that will be used to execute the lambda function."

  name               = "${var.name}-${var.env}-${var.region}-iam_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_policy" {
  description = "The iam policy that provides permissions to the lambda function."

  name   = "${var.name}-${var.env}-${var.region}-iam_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ---------------------------------------------------------------------------
# IAM - end
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Cloudwatch - start
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "lambda_cloudwatch_logs" {
  name              = "${var.name}-${var.env}-${var.region}-lambda_logs"
  retention_in_days = var.cloudwatch_log_retention_in_days
}

# ---------------------------------------------------------------------------
# Cloudwatch - end
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Lambda - start
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Lambda - end
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# API Gateway - start
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# API Gateway - end
# ---------------------------------------------------------------------------

variable "api_throttling_burst_limit" {
  description = "The maximum burst of concurrent requests the API Gateway stage will accept before throttling."
  type        = number
  default     = 1
}

variable "api_throttling_rate_limit" {
  description = "The steady-state number of requests per second the API Gateway stage will accept before throttling."
  type        = number
  default     = 1
}

variable "bucket_force_destroy" {
  description = "Whether to force destroy the S3 bucket even if it contains objects."
  type        = bool
}

variable "cloudwatch_log_retention_in_days" {
  description = "The number of days to retain cloudwatch logs."
  type        = string
  default     = "1"
}

variable "env" {
  description = "The environment to deploy all resources."
  type        = string
}

variable "lambda_reserved_concurrent_executions" {
  description = "The maximum number of concurrent executions reserved for the lambda function."
  type        = number
  default     = 1
}

variable "lambda_runtime" {
  description = "The runtime version to use for the lambda function."
  type        = string
  default     = "python3.12"
}

variable "name" {
  description = "The name of the app."
  type        = string
  default     = "slackbot_demo"
}

variable "region" {
  description = "The AWS region to deploy all resources."
  type        = string
  default     = "us-west-2"
}

variable "repo" {
  description = "The name of the repository."
  type        = string
  default     = "slackbot_demo"
}

variable "slack_bot_token" {
  description = "The bot token used to authenticate calls to the Slack API."
  type        = string
  sensitive   = true
}

variable "slack_signing_secret" {
  description = "The signing secret used to verify requests are coming from Slack."
  type        = string
  sensitive   = true
}

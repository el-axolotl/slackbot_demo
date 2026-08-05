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

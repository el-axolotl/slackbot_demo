variable "name" {
  description = "The name of the app."

  type    = string
  default = "slackbot_demo"
}

variable "region" {
  description = "The AWS region to deploy all resources."

  type    = string
  default = "us-west-2"
}

variable "env" {
  description = "The environment to deploy all resources."

  type = string
}

variable "cloudwatch_log_retention_in_days" {
  description = "The number of days to retain cloudwatch logs."

  type    = string
  default = "1"
}

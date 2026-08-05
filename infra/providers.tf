terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      app         = "slackbot_demo",
      environment = var.env
    }
  }

}

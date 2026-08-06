terraform {
  backend "s3" {
    bucket  = "tfstate-axolotl-prod"
    key     = "slackbot_demo/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
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
      app  = "slackbot_demo",
      env  = var.env,
      repo = var.repo
      purpose = "home-lab"
    }
  }
}

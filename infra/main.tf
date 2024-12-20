provider "aws" {
  region = var.region

  default_tags {
    tags = {
      app         = "slackbot_demo",
      environment = var.env
    }
  }

}

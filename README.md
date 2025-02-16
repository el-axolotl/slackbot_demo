# slackbot_demo

## Objective:
Build a slack bot using Python & its open source libraries. For example, you might choose to use the Bolt Library. Deploy this slackbot to AWS using Terraform, either to the EC2 free tier (with or without a docker container), Lightsail, or to AWS lambda with an API gateway, or any other method you’d choose.

## Bonus: 
Consider adding a CI/CD pipeline that will deploy code updates to your infrastructure of choice. You can use Github actions or any other CI/CD platform.

## Acceptance Criteria:
A slackbot that responds to input from a human or some other event. Deployed to AWS using Terraform.

## Slack Integration:
The link below will teach you how to set up the Slack application and how to integrate the Lambda with your space:
- https://medium.com/glasswall-engineering/how-to-create-a-slack-bot-using-aws-lambda-in-1-hour-1dbc1b6f021c

## Learning Resources:
Rest API Gateway Trigger Example: https://gist.github.com/magnetikonline/c314952045eee8e8375b82bc7ec68e88

## Testing
- Stand up infrastructure by running command in /infra directory.
    ```
    terraform init
    terraform apply -var-file="_$(terraform workspace show).tfvars"
    ```
- Test API Gateway
    ```
    curl "$(terraform output -raw base_url)/hello"
    ```
- Test lambda function
    ```
    aws lambda invoke --region=us-west-2 --function-name=$(terraform output -raw function_name) response.json
    ```

## Cleanup Resources
- Plan Destroy
    ```
    terraform plan -destroy -var-file="_$(terraform workspace show).tfvars"
    ```
- Terraform Destroy
    ```
    terraform destroy -var-file="_$(terraform workspace show).tfvars"
    ```

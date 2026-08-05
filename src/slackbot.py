import base64
import hashlib
import hmac
import json
import os
import time

import boto3

secrets_client = boto3.client("secretsmanager")


def get_secret(secret_arn):
    return secrets_client.get_secret_value(SecretId=secret_arn)["SecretString"]


def is_valid_slack_request(event, signing_secret):
    headers = event.get('headers', {})
    timestamp = headers.get('x-slack-request-timestamp')
    slack_signature = headers.get('x-slack-signature')

    if not timestamp or not slack_signature:
        return False

    try:
        timestamp = int(timestamp)
    except ValueError:
        return False

    if abs(time.time() - timestamp) > 60 * 5:
        return False

    body = event.get('body', '')
    if event.get('isBase64Encoded'):
        body = base64.b64decode(body).decode('utf-8')

    basestring = f"v0:{timestamp}:{body}".encode('utf-8')
    computed_signature = 'v0=' + hmac.new(signing_secret.encode('utf-8'), basestring, hashlib.sha256).hexdigest()

    return hmac.compare_digest(computed_signature, slack_signature)


def main(event, context):
    slack_signing_secret = get_secret(os.environ["SLACK_SIGNING_SECRET_ARN"])

    if not is_valid_slack_request(event, slack_signing_secret):
        return {
            'statusCode': 401,
            'body': json.dumps('Invalid request signature.')
        }

    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({'response_type': 'in_channel', 'text': 'Hello world!'})
    }

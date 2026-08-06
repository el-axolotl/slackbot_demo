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
    headers = {k.lower(): v for k, v in event.get('headers', {}).items()}
    timestamp = headers.get('x-slack-request-timestamp')
    slack_signature = headers.get('x-slack-signature')

    if not timestamp or not slack_signature:
        return False

    try:
        timestamp = int(timestamp)
    except ValueError:
        return False

    age = abs(time.time() - timestamp)
    if age > 60 * 5:
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

    account_options = [
        {'text': {'type': 'plain_text', 'text': account}, 'value': account}
        for account in ['1111111', '2222222', '3333333', '4444444', '5555555']
    ]

    expiration_options = [
        {'text': {'type': 'plain_text', 'text': f'{days} days'}, 'value': str(days)}
        for days in [90, 180, 360]
    ]

    blocks = [
        {
            'type': 'header',
            'text': {'type': 'plain_text', 'text': 'Secret Rotation Runbook'}
        },
        {
            'type': 'section',
            'text': {'type': 'mrkdwn', 'text': 'Select the AWS account to rotate secrets for:'}
        },
        {
            'type': 'actions',
            'block_id': 'account_select_block',
            'elements': [
                {
                    'type': 'static_select',
                    'action_id': 'account_select',
                    'placeholder': {'type': 'plain_text', 'text': 'Select an AWS account'},
                    'options': account_options
                }
            ]
        },
        {
            'type': 'section',
            'text': {'type': 'mrkdwn', 'text': 'Set an expiration for the rotated secrets:'}
        },
        {
            'type': 'actions',
            'block_id': 'expiration_select_block',
            'elements': [
                {
                    'type': 'radio_buttons',
                    'action_id': 'expiration_select',
                    'options': expiration_options
                }
            ]
        }
    ]

    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({'response_type': 'ephemeral', 'blocks': blocks})
    }

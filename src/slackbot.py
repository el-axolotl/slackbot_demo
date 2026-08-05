import json

def main(event, context):

    return {
        'statusCode': 200,
        'body': json.dumps('Hello world!'),
        'eventObject': json.dumps(event)
    }
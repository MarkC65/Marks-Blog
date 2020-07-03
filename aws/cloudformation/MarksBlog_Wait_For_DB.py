import json

def lambda_handler(event, context):
    import boto3

    client = boto3.client('rds')

    waiter = client.get_waiter('db_instance_available')

    waiter.wait(
        DBInstanceIdentifier='prod',
        WaiterConfig={
            'Delay': 15,
            'MaxAttempts': 40
        }
    )

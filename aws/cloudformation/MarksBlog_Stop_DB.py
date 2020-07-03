import json

def lambda_handler(event, context):
    import boto3

    client = boto3.client('rds')

    response = client.describe_db_instances(
        DBInstanceIdentifier='prod',
    )

    if (response['DBInstances'][0]['DBInstanceStatus']) == "available":
        response = client.stop_db_instance(
            DBInstanceIdentifier='prod'
        )

        return 0
    else:
        return 1

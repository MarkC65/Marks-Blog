from __future__ import print_function
import boto3
import botocore
import json
import traceback
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

patch_all()

code_pipeline = boto3.client('codepipeline')
client_r53 = boto3.client('route53')
client_ec2 = boto3.client('ec2')
client_s3 = boto3.client('s3')

def put_job_success(job, message):
    """Notify CodePipeline of a successful job
    
    Args:
        job: The CodePipeline job ID
        message: A message to be logged relating to the job status
        
    Raises:
        Exception: Any exception thrown by .put_job_success_result()
    
    """
    print('Putting job success')
    print(message)
    code_pipeline.put_job_success_result(jobId=job)

def put_job_failure(job, message):
    """Notify CodePipeline of a failed job
    
    Args:
        job: The CodePipeline job ID
        message: A message to be logged relating to the job status
        
    Raises:
        Exception: Any exception thrown by .put_job_failure_result()
    
    """
    print('Putting job failure')
    print(message)
    code_pipeline.put_job_failure_result(jobId=job, failureDetails={'message': message, 'type': 'JobFailed'})
 
def lambda_handler(event, context):
    """The Lambda function handler
    Args:
        event: The event passed by Lambda
        context: The context passed by Lambda
    """
    try:
        # Extract the Job ID and UserParameters
        job_id = event['CodePipeline.job']['id']
        user_params = event['CodePipeline.job']['data']['actionConfiguration']['configuration']['UserParameters']
        decoded_parameters = json.loads(user_params)
        # output_arti = event['CodePipeline.job']['data']['outputArtifacts'][0]
        output_arti_s3bucket = event['CodePipeline.job']['data']['outputArtifacts'][0]['location']['s3Location']['bucketName']
        output_arti_s3key = event['CodePipeline.job']['data']['outputArtifacts'][0]['location']['s3Location']['objectKey']
        # print ("Output Artifacts: "+output_arti)
        # print ("Bucket: "+output_arti_s3bucket)
        # print ("Key: "+output_arti_s3key)

    except Exception as e:
        # We're expecting the user parameters to be encoded as JSON
        # so we can pass multiple values. If the JSON can't be decoded
        # then fail the job with a helpful message.
        raise Exception('UserParameters could not be decoded as JSON')
        put_job_failure(job_id, 'Function exception: ' + str(e))

    if 'dns-domain-by-name' not in decoded_parameters:
        # Validate that the stack is provided, otherwise fail the job
        # with a helpful message.
        raise Exception('Your UserParameters JSON must include the DNS Domain name')
        put_job_failure(job_id, 'Function exception: ' + str(e))
    
    if 'A-record' not in decoded_parameters:
        # Validate that the artifact name is provided, otherwise fail the job
        # with a helpful message.
        raise Exception('Your UserParameters JSON must include the A Record name to be created')
        put_job_failure(job_id, 'Function exception: ' + str(e))
    
    if 'EC2-Key' not in decoded_parameters:
        # Validate that the template file is provided, otherwise fail the job
        # with a helpful message.
        raise Exception('Your UserParameters JSON must include the EC2 Key of the running EC2-Instance')
        put_job_failure(job_id, 'Function exception: ' + str(e))
        
    if 'EC2-Value' not in decoded_parameters:
        # Validate that the template file is provided, otherwise fail the job
        # with a helpful message.
        raise Exception('Your UserParameters JSON must include the EC2-Value of the running EC2-Instance')
        put_job_failure(job_id, 'Function exception: ' + str(e))
    
    dns_domain_by_name = decoded_parameters['dns-domain-by-name']
    a_record = decoded_parameters['A-record']
    ec2_key = decoded_parameters['EC2-Key']
    ec2_value = decoded_parameters['EC2-Value']

    try:
        r53_response = client_r53.list_hosted_zones_by_name(
            DNSName=dns_domain_by_name
        )
        # print (r53_response)
        zone_id = r53_response['HostedZones'][0]['Id'].split("/")[2]
        # print ("Hosted ZoneID:"+zone_id)
    except Exception as e:
        # If any other exceptions which we didn't expect are raised
        # then fail the job and log the exception message.
        print('Function failed during Route 53 list_hosted_zones_by_name call due to exception.') 
        print(e)
        # traceback.print_exc()
        put_job_failure(job_id, 'Function exception: ' + str(e))

    try:
        ec2_response = client_ec2.describe_instances(
            Filters=[
                {
                    'Name': 'tag:'+ec2_key,
                    'Values': [
                        ec2_value,
                    ]
                }
            ]
        )
        # print (ec2_response)
        public_ip = ec2_response['Reservations'][0]['Instances'][0]['PublicIpAddress']
        # print ("Public IP: "+public_ip)

    except Exception as e:
        # If any other exceptions which we didn't expect are raised
        # then fail the job and log the exception message.
        print('Function failed during EC2 describe_instances call due to exception.') 
        print(e)
        # traceback.print_exc()
        put_job_failure(job_id, 'Function exception: ' + str(e))

    try:
        dns_response = client_r53.change_resource_record_sets(
            HostedZoneId = zone_id,
            ChangeBatch={
                'Comment': 'Marks-Blog Instance in Staging environment',
                'Changes': [
                    {
                        'Action': 'CREATE',
                        'ResourceRecordSet': {
                            'Name': a_record+'.'+dns_domain_by_name,
                            'Type': 'A',
                            'TTL': 600,
                            'ResourceRecords': [{
                              'Value': public_ip
                            }]
                        }
                    }
                ]
            }
        )

    except Exception as e:
        # If any other exceptions which we didn't expect are raised
        # then fail the job and log the exception message.
        print('Function failed during Route 53 change_resource_record_sets call due to exception.') 
        print(e)
        # traceback.print_exc()
        put_job_failure(job_id, 'Function exception: ' + str(e))

    try:
        s3_response = client_s3.put_object(
            Body = '{"HostedZoneId":"'+zone_id+'","Name":"'+a_record+'.'+dns_domain_by_name+'","Type":"A","TTL":"600","Value":"'+public_ip+'"}',
            Bucket = output_arti_s3bucket,
            Key = output_arti_s3key,
            ServerSideEncryption = 'aws:kms'
            # SSEKMSKeyId='string'
        )

    except Exception as e:
        # If any other exceptions which we didn't expect are raised
        # then fail the job and log the exception message.
        print('Function failed during S3 put_object call due to exception.') 
        print(e)
        # traceback.print_exc()
        put_job_failure(job_id, 'Function exception: ' + str(e))

    put_job_success(job_id, 'List Hosted Zone By Name call completed.') 

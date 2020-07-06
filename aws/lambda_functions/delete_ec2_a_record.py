from __future__ import print_function
import boto3
import json
import traceback
import botocore.response as br

code_pipeline = boto3.client('codepipeline')
client_r53 = boto3.client('route53')
# client_ec2 = boto3.client('ec2')
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
        input_arti_s3bucket = event['CodePipeline.job']['data']['inputArtifacts'][0]['location']['s3Location']['bucketName']
        input_arti_s3key = event['CodePipeline.job']['data']['inputArtifacts'][0]['location']['s3Location']['objectKey']
        # decoded_parameters = json.loads(user_params)

    except Exception as e:
        # We're expecting the user parameters to be encoded as JSON
        # so we can pass multiple values. If the JSON can't be decoded
        # then fail the job with a helpful message.
        raise Exception('InputArtifacts not available.')
        put_job_failure(job_id, 'Function exception: ' + str(e))
        return

    # print ("S3 Bucket: "+input_arti_s3bucket)
    # print ("S3 Key: "+input_arti_s3key)

    try:
        s3_response = client_s3.get_object(
            Bucket = input_arti_s3bucket,
            Key = input_arti_s3key,
        )
        # print (s3_response['Body'])
        s3_streaming_obj = br.StreamingBody(s3_response['Body'],s3_response['ContentLength'])
        dns_a_record = json.loads(s3_streaming_obj.read().decode("utf-8"))
        # print ("DNS Record data: "+dns_a_record)
        
    except Exception as e:
        # If any other exceptions which we didn't expect are raised
        # then fail the job and log the exception message.
        print('Function failed during S3 get_object call due to exception.') 
        print(e)
        # traceback.print_exc()
        put_job_failure(job_id, 'Function exception: ' + str(e))

    if 'HostedZoneId' not in dns_a_record:
        # Validate that the stack is provided, otherwise fail the job
        # with a helpful message.
        raise Exception('InputArtifact JSON must include the HostedZoneId')
        put_job_failure(job_id, 'Function exception: ' + str(e))
    
    if 'Name' not in dns_a_record:
        # Validate that the stack is provided, otherwise fail the job
        # with a helpful message.
        raise Exception('InputArtifact JSON must include the DNS Domain name')
        put_job_failure(job_id, 'Function exception: ' + str(e))
    
    if 'Type' not in dns_a_record:
        # Validate that the artifact name is provided, otherwise fail the job
        # with a helpful message.
        raise Exception('InputArtifact JSON must include the DNS Record type')
        put_job_failure(job_id, 'Function exception: ' + str(e))
    
    if 'TTL' not in dns_a_record:
        # Validate that the template file is provided, otherwise fail the job
        # with a helpful message.
        raise Exception('InputArtifact JSON must include the DNS Record TTL value')
        put_job_failure(job_id, 'Function exception: ' + str(e))
    
    if 'Value' not in dns_a_record:
        # Validate that the template file is provided, otherwise fail the job
        # with a helpful message.
        raise Exception('InputArtifact JSON must include the DNS Record IP Address')
        put_job_failure(job_id, 'Function exception: ' + str(e))
    
    try:
        dns_response = client_r53.change_resource_record_sets(
            HostedZoneId = dns_a_record['HostedZoneId'],
            ChangeBatch={
                'Comment': 'Marks-Blog Instance in Staging environment',
                'Changes': [
                    {
                        'Action': 'DELETE',
                        'ResourceRecordSet': {
                            'Name': dns_a_record['Name'],
                            'Type': dns_a_record['Type'],
                            'TTL': int(dns_a_record['TTL']),
                            'ResourceRecords': [{
                              'Value': dns_a_record['Value']
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

    put_job_success(job_id, 'Delete EC2 A Record call completed.')

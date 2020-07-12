from __future__ import print_function
import boto3
import traceback
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

patch_all()

client = boto3.client('rds')
code_pipeline = boto3.client('codepipeline')

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
        # Extract the Job ID
        job_id = event['CodePipeline.job']['id']
        waiter = client.get_waiter('db_instance_available')
        waiter.wait(
            DBInstanceIdentifier='prod',
            WaiterConfig={
                'Delay': 15,
                'MaxAttempts': 40
            }
        )
        put_job_success(job_id, 'RDS db_instance_available get_waiter call completed.') 
    except Exception as e:
        # If any other exceptions which we didn't expect are raised
        # then fail the job and log the exception message.
        print('Function failed due to exception.') 
        print(e)
        traceback.print_exc()
        put_job_failure(job_id, 'Function exception: ' + str(e))

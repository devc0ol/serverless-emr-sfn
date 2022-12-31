import json
import boto3
import logging
from commons import start_job,get_config_from_s3

logger = logging.getLogger()
logger.setLevel(logging.INFO)
emrs_client = boto3.client('emr-serverless')

def lambda_handler(event, context):
    
    response=start_job(event['LoadName'])

    return {
        "jobRunId" : response['jobRunId'],
        "applicationId" : response['applicationId'],
        "LoadName" : event['LoadName']
        }
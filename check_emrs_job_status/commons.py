import logging
import boto3
import json
import time

emrs_client = boto3.client('emr-serverless')
logger = logging.getLogger()
logger.setLevel(logging.INFO)

    
def cleanup_application(applicationId):
    logger.info('Cleanup Started  : Stopping Application')
    emrs_client.stop_application(
    applicationId=applicationId
    )
    time.sleep(5)
    emrs_client.delete_application(
    applicationId=applicationId
    )
    logger.info('Cleanup Completed  : Deleted Application')
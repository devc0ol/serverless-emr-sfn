import json
import logging
import boto3
import time
from datetime import datetime 
from commons import cleanup_application

now = datetime.now()
now_string = now.strftime("%Y%m%d%H%M%S")
today = now.strftime("%Y%m%d")

logger = logging.getLogger()
logger.setLevel(logging.INFO)

emrs_client = boto3.client('emr-serverless')

def lambda_handler(event, context):
    
    try:
        applicationId=event['applicationId']
        jobRunId=event['jobRunId']
        LoadName=event['LoadName']
        
        response = emrs_client.get_job_run(
        applicationId=applicationId,
        jobRunId=jobRunId
        )
        logger.info(response) 
        name=str(response['jobRun']['name'])
        state=str(response['jobRun']['state'])
        updatedAt=response['jobRun']['updatedAt']
        
        status=''
        if (str(state)=='SUBMITTED' or str(state)=='PENDING' or str(state)=='SCHEDULED' or str(state)=='RUNNING' or str(state)=='CANCELLING'):
            logger.info('Job Running')
            status='RUNNING'
        elif str(state)=='SUCCESS':
            
            status='SUCCEEDED'
            time.sleep(60)
            vCPUHour=float(response['jobRun']['totalResourceUtilization']['vCPUHour'])
            memoryGBHour=float(response['jobRun']['totalResourceUtilization']['memoryGBHour'])
            storageGBHour=float(response['jobRun']['totalResourceUtilization']['storageGBHour'])
            total_run_duration=str(response['jobRun']['updatedAt']-response['jobRun']['createdAt'])
            updatedAt=response['jobRun']['updatedAt']
            cleanup_application(applicationId)
            
        elif (str(state)=='FAILED'  or 'CANCELLED'):
            
            logger.info('Job Failed/Cancelled')
            status='FAILED'
            time.sleep(60)
            vCPUHour=float(response['jobRun']['totalResourceUtilization']['vCPUHour'])
            memoryGBHour=float(response['jobRun']['totalResourceUtilization']['memoryGBHour'])
            storageGBHour=float(response['jobRun']['totalResourceUtilization']['storageGBHour'])
            total_run_duration=str(response['jobRun']['updatedAt']-response['jobRun']['createdAt'])
            updatedAt=response['jobRun']['updatedAt']
            cleanup_application(applicationId)
        else:
            logger.info('Status Unknown')
        
        
        return {
            'status': status,
            'LoadName': LoadName,
            'jobRunId' : jobRunId,
            'applicationId' : applicationId
        }

    except Exception as e:
        logger.error("Error : "+str(e))
        status='Failed'

    
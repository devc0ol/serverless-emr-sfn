import boto3
import logging
import time
import tempfile
import os
import configparser
from datetime import datetime

now = datetime.now()
now_string = now.strftime("%Y%m%d%H%M%S")
today = now.strftime("%Y%m%d")
logger = logging.getLogger()
logger.setLevel(logging.INFO)

emrs_client = boto3.client('emr-serverless')

def start_job(LoadName,application_name='EMRS-SparkPi'):
    application_id=application_check(application_name)
    logger.info("Getting Parameters from Spark Config")
    time.sleep(2)
    logger.info("Starting Job Run on ApplicationId : "+str(application_id))
    response = emrs_client.start_job_run(
    applicationId=application_id,
    executionRoleArn='<role created out from terraform output>',
    jobDriver={
        'sparkSubmit': {
            'entryPoint': "s3://code_bucket/code/SparkPi.py",
            'sparkSubmitParameters': "--executor-cores 2 --executor-memory 4G --num-executors 2 --driver-memory 2G"
        },

    },
    configurationOverrides={
        'monitoringConfiguration': {
            's3MonitoringConfiguration': {
                'logUri': "s3://bucket_name/log_folder/"+LoadName+'/'+now_string+'/'
            }
        }
    },
    executionTimeoutMinutes=300,
    name=LoadName
    )
    
    return response

def application_check(application_name='EMRS-SparkPi'):
    logger.info("Checking if application "+str(application_name)+" exists")
    response = emrs_client.list_applications(
        maxResults=10,
        states=[
            'CREATING','CREATED','STARTING','STARTED','STOPPING','STOPPED'
        ]
    )

    exists_flag=0
    for row in response['applications']:
        if row['name']==application_name:
            exists_flag=1
            application_id=row['id']
    
    if exists_flag==1:
        logger.info("Application "+str(application_name)+" exists with application_id : "+str(application_id))
        return application_id
    else:
        logger.info("Application is deleted")
        start_application(application_name)
        time.sleep(10)
        return application_check(application_name)
        

def start_application(application_name='EMRS-SparkPi'):
    logger.info("Starting new application with name: "+str(application_name))
    response = emrs_client.create_application(
    name=application_name,
    releaseLabel='emr-6.8.0',
    type='SPARK',
    initialCapacity={
        'DRIVER': {
            'workerCount': 2,
            'workerConfiguration': {
                'cpu': '4vCPU',
                'memory': '16GB',
                'disk': '20GB'
            }
        }
    },
    maximumCapacity={
        'cpu': '100vCPU',
        'memory': '400GB',
        'disk': '500GB'
    },
    autoStartConfiguration={
        'enabled': True
    },
    autoStopConfiguration={
        'enabled': True,
        'idleTimeoutMinutes': 10
    },
    networkConfiguration={
        'subnetIds': [
            'subnet-name'
        ],
        'securityGroupIds': [
            'sg-name'
        ]
    }
    )

def get_config_from_s3():
    try:
        bucket_name = os.environ['conf_bucket']
        key =  os.environ['conf_key']
        s3 = boto3.resource('s3')
        bucket = s3.Bucket(bucket_name)
        cfg = (bucket.Object(key)).get()
        conf=cfg['Body'].read().decode('utf-8')
        config = configparser.ConfigParser()
        config.read_string(conf)
        return config
    except Exception as e:
        print(e)
        

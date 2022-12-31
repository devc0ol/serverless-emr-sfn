# Serverless Exection of Spark jobs using EMR-Serverless/Step-Functions and Lambdas
Example of EMR-Serverless with Step Function &amp; Lambda.

Pre-requisites are as below:

Terraform installed on your deployment environment. Please follow steps [here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
Deployment and Create Permissions on AWS Account.

The deployment is completely through Terraform but there are few configuration changes that would be required before you can run the terraform package.

Step 1 : Upload the SparkPi.py file to a S3 location of your choice. Copy the S3 url and paste it in trigger_job/commons.py file, where entrypoint is specified.

Step 2 : If you have a log folder already created in s3 bucket then point the 'logUri': "s3://bucket_name/log_folder/" to that bucket and key in trigger_job/commons.py

Step 3 : In start_application function in trigger_job/commons.py configure the network connections for subnet and security groups under networkConfiguration. This is an optionable step as network configurations can be ignored if data is not be sent outside the EMR job. Delete the section for networkConfiguration if not being used.

Step 4 : You can play around the initial configuration of the application. But do remember the limits. More info [here](https://docs.aws.amazon.com/emr/latest/EMR-Serverless-UserGuide/application-capacity.html#max-capacity)


Step 5 : Check for deployment region in variables.tf. Default is set to 'us-east-1'.

Step 6 : Zip the contents of both the lambdas using the following commands
```
zip -rj check_emrs_job_status.zip check_emrs_job_status/*.py
zip -rj trigger_job.zip trigger_job/*.py
```

Step 7 : Execute the terraform template after executing the following commands and keep an eye on the output arn of emr_serverless_execution_role_arn

## Terraform Commands
### Terraform Initiate Project
```terraform init```
### Terraform Check Templates
```terraform fmt```
### Terraform Run Template
```terraform apply```

Step 8 : In trigger_job commons.py file executionRoleArn='<role created out from terraform output>' needs to be changed after the first run of terraform is complete. This can be gotten from the above emr_serverless_execution_role_arn from outputs. Once replaced, execute Step 6 for the trigger_job folder and zip it again. Once again deploy the trigger_job lambda by using terraform apply.

Step 9 : Verify if 15 objects have been created.

Step 10 : Go to your step function and trigger your job with the following payload.

```
{
	"LoadName" : "SparkPi"
}
```

And you should see 
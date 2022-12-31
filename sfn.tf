resource "aws_sfn_state_machine" "sfn_emr_serverless" {
  name     = "sfn_emr_serverless"
  role_arn = "${aws_iam_role.sfn_execution_role.arn}"

  definition = <<EOF
{
  "Comment": "A description of my state machine",
  "StartAt": "EMRS Job Trigger",
  "States": {
    "EMRS Job Trigger": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${aws_lambda_function.emrs_trigger_job.arn}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Next": "EMRS Check Job Status"
    },
    "EMRS Check Job Status": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "FunctionName": "${aws_lambda_function.check_emrs_job_status.arn}:$LATEST",
        "Payload.$": "$"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Next": "Check Status"
    },
    "Check Status": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.status",
          "StringMatches": "SUCCEEDED",
          "Next": "Success"
        },
        {
          "Variable": "$.status",
          "StringMatches": "FAILED",
          "Next": "Fail"
        }
      ],
      "Default": "Wait 30 secs"
    },
    "Wait 30 secs": {
      "Type": "Wait",
      "Seconds": 60,
      "Next": "EMRS Check Job Status"
    },
    "Success": {
      "Type": "Succeed"
    },
    "Fail": {
      "Type": "Fail"
    }
  }
}
EOF

  #depends_on = [aws_iam_role_policy_attachment.iam_for_sfn_attach_policy_invoke_lambda, aws_lambda_function.check_emrs_job_status]

}

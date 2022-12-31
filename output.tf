output "emrs_trigger_job_arn" {
  value = aws_lambda_function.emrs_trigger_job.arn
}

output "check_emrs_job_status_arn" {
  value = aws_lambda_function.check_emrs_job_status.arn
}

output "aws_sfn_state_machine" {
  value = aws_sfn_state_machine.sfn_emr_serverless.arn
}


output "emr_serverless_lambda_role_arn" {
    value = aws_iam_role.emr_serverless_lambda_role.arn
  }


output "emr_serverless_sfn_execution_role_arn" {
    value = aws_iam_role.sfn_execution_role.arn
  }

output "emr_serverless_execution_role_arn" {
    value = aws_iam_role.emr_serverless_execution_role.arn
  }

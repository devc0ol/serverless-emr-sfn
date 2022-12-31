resource "aws_lambda_layer_version" "emr_serverless_layer" {
  filename   = "emr-serverless-layer.zip"
  layer_name = "emr_serverless_layer"

  compatible_runtimes = ["python3.9"]
}

resource "aws_lambda_function" "emrs_trigger_job" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "trigger_job.zip"
  function_name = "emrs_trigger_job"
  role          = aws_iam_role.emr_serverless_lambda_role.arn
  handler       = "lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("SparkPi.zip"))}"
  source_code_hash = filebase64sha256("trigger_job.zip")

  runtime = "python3.9"
  layers = [aws_lambda_layer_version.emr_serverless_layer.arn]
  timeout = 120
  ephemeral_storage {
    size = 512 # Min 512 MB and the Max 10240 MB
  }
  #depends_on = [aws_iam_role_policy_attachment.emr_serverless_lambda_role_attachment, aws_lambda_layer_version.emr_serverless_layer]
  tags       = { "Name" : "emr_serverless" }
}


resource "aws_lambda_function" "check_emrs_job_status" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "check_emrs_job_status.zip"
  function_name = "check_emrs_job_status"
  role          = aws_iam_role.emr_serverless_lambda_role.arn
  handler       = "lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("SparkPi.zip"))}"
  source_code_hash = filebase64sha256("check_emrs_job_status.zip")

  runtime = "python3.9"
  layers = [aws_lambda_layer_version.emr_serverless_layer.arn]
  timeout = 120
  ephemeral_storage {
    size = 512 # Min 512 MB and the Max 10240 MB
  }
  #depends_on = [aws_iam_role_policy_attachment.emr_serverless_lambda_role_attachment, aws_lambda_function.emrs_trigger_job]
  tags       = { "Name" : "emr_serverless" }
}


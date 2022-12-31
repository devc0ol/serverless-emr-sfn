resource "aws_iam_policy" "lambda_basic_execution_policy" {
  name        = "lambda_basic_execution_policy"
  description = "Basic execution policy for lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Effect = "Allow",
            Action =  [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            Resource = [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
})

}

resource "aws_iam_policy" "emr_serverless_execution_policy" {
  name        = "emr_serverless_execution_policy"
  description = "EMR Serverless execution policy for lambda"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }
    ]
})

}


resource "aws_iam_policy" "emr_serverless_lambda_policy" {
  name        = "emr_serverless_lambda_policy"
  description = "Execution policy for lambda"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EMRServerlessLambdaRole",
            "Effect": "Allow",
            "Action": [
                "emr-serverless:CreateApplication",
                "emr-serverless:StopApplication",
                "emr-serverless:GetApplication",
                "emr-serverless:GetJobRun",
                "emr-serverless:StartJobRun",
                "emr-serverless:ListApplications",
                "emr-serverless:DeleteApplication",
                "emr-serverless:ListJobRuns",
                "emr-serverless:CancelJobRun",
                "emr-serverless:StartApplication"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "ec2:AssignPrivateIpAddresses",
                "ec2:UnassignPrivateIpAddresses"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:PassRole"
            ],
            "Resource": "${aws_iam_role.emr_serverless_execution_role.arn}"
        }
        ]
})

}

resource "aws_iam_role" "emr_serverless_lambda_role" {
  name        = "emr_serverless_lambda_role"
  description = "Execution role for lamnda"
  lifecycle {
    ignore_changes = [
      tags,
      permissions_boundary
    ]
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal =  {
            Service = "lambda.amazonaws.com"
            },
        Effect = "Allow",
        Sid = ""
        }

    ]
  })
  #depends_on = [aws_iam_policy.emr_serverless_lambda_policy]
}

resource "aws_iam_role" "emr_serverless_execution_role" {
  name        = "emr_serverless_execution_role"
  description = "Execution role for lamnda"
  lifecycle {
    ignore_changes = [
      tags,
      permissions_boundary
    ]
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = [
                    "emr-serverless.amazonaws.com"
                ]
        }
      }

    ]
  })
  depends_on = [aws_iam_policy.emr_serverless_execution_policy]
}

resource "aws_iam_role" "sfn_execution_role" {
  name = "sfn_execution_role"
  lifecycle {
    ignore_changes = [
      tags,
      permissions_boundary
    ]
  }
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "sfn_policy_invoke_lambda" {
  name        = "sfn_policy_invoke_lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:InvokeAsync"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "emr_serverless_execution_role_attachment" {
  role       = aws_iam_role.emr_serverless_execution_role.name
  policy_arn = aws_iam_policy.emr_serverless_execution_policy.arn
  #depends_on = [aws_iam_role.emr_serverless_execution_role]
}

resource "aws_iam_role_policy_attachment" "emr_serverless_lambda_role_attachment" {
  role       = aws_iam_role.emr_serverless_lambda_role.name
  policy_arn = aws_iam_policy.emr_serverless_lambda_policy.arn
  #depends_on = [aws_iam_role.emr_serverless_lambda_role]
}

resource "aws_iam_role_policy_attachment" "emr_serverless_lambda_basic_role_attachment" {
  role       = aws_iam_role.emr_serverless_lambda_role.name
  policy_arn = aws_iam_policy.lambda_basic_execution_policy.arn
  #depends_on = [aws_iam_role.emr_serverless_lambda_role]
}

resource "aws_iam_role_policy_attachment" "iam_for_sfn_attach_policy_invoke_lambda" {
  role       = "${aws_iam_role.sfn_execution_role.name}"
  policy_arn = "${aws_iam_policy.sfn_policy_invoke_lambda.arn}"
}

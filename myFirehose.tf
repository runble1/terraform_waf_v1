# ## #
# S3 #
# ## #
resource "aws_s3_bucket" "bucket" {
  bucket = "tf-test-bucket-waf"
  acl    = "private"
  region = "us-east-1"
}

# ####### #
# Kinesis #
# ####### #
resource "aws_iam_role" "firehose_role" {
  name = "firehose_test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_kinesis_firehose_delivery_stream" "test_stream" {
  name        = "aws-waf-logs-terraform-kinesis-firehose-test-stream"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.bucket.arn
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.cloudwatch_log_group.name
      log_stream_name = aws_cloudwatch_log_stream.cloudwatch_log_stream.name
    }
  }
}

# ############### #
# CloudWatch Logs #
# ############### #
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "aws-waf-logs-cloudwatch-log-group"
}

resource "aws_cloudwatch_log_stream" "cloudwatch_log_stream" {
  name           = "aws-waf-logs-cloudwatch-log-stream"
  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group.name
}

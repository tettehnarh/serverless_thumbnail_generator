# Declare required providers and their versions
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "4.36.1"
        }
        archive = {
            source = "hashicorp/archive"
            version = "~> 2.2"
        }
    }
    required_version = ">= 1.0"
}

provider "aws" {
    region = var.aws_region
}

# Define IAM policy for granting S3 permissions to the Lambda function
resource "aws_iam_policy" "thumbnail_s3_policy" {
  name   = "thumbnail_s3_policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::${var.original_image_bucket_name}/*"
      },
      {
        "Effect": "Allow",
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::${var.thumbnail_image_bucket_name}/*"
      }
    ]
  })
}

# Define IAM role for the Lambda function to assume
resource "aws_iam_role" "thumbnail_lambda_role" {
  name               = "thumbnail_lambda_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# Attach the S3 policy to the Lambda role
resource "aws_iam_policy_attachment" "thumbnail_role_s3_policy_attachment" {
  name       = "thumbnail_role_s3_policy_attachment"
  roles      = [aws_iam_role.thumbnail_lambda_role.name]
  policy_arn = aws_iam_policy.thumbnail_s3_policy.arn
}

# Attach the AWSLambdaBasicExecutionRole policy to the Lambda role
resource "aws_iam_policy_attachment" "thumbnail_role_lambda_policy_attachment" {
  name       = "thumbnail_role_lambda_policy_attachment"
  roles      = [aws_iam_role.thumbnail_lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create a ZIP archive containing the Lambda function code
data "archive_file" "thumbnail_lambda_source_archive" {
  type        = "zip"
  source_dir  = "${path.module}/${var.lambda_source_dir}"
  output_path = "${path.module}/my-deployment.zip"
}

# Define the Lambda function
resource "aws_lambda_function" "thumbnail_lambda" {
  function_name    = var.lambda_function_name
  filename         = "${path.module}/my-deployment.zip"
  runtime          = "python3.9"
  handler          = "app.lambda_handler"
  memory_size      = var.lambda_memory_size
  source_code_hash = data.archive_file.thumbnail_lambda_source_archive.output_base64sha256
  role             = aws_iam_role.thumbnail_lambda_role.arn
  layers           = ["arn:aws:lambda:${var.aws_region}:770693421928:layer:Klayers-p39-pillow:1"]
}

# Create S3 buckets for the original images and thumbnails
resource "aws_s3_bucket" "thumbnail_original_image_bucket" {
  bucket = var.original_image_bucket_name
}

resource "aws_s3_bucket" "thumbnail_image_bucket" {
  bucket = var.thumbnail_image_bucket_name
}

# Allow S3 to invoke the Lambda function when new objects are created
resource "aws_lambda_permission" "thumbnail_allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.thumbnail_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.thumbnail_original_image_bucket.arn
}

# Configure S3 bucket notification to trigger the Lambda function when new objects are created
resource "aws_s3_bucket_notification" "thumbnail_notification" {
  bucket = aws_s3_bucket.thumbnail_original_image_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.thumbnail_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.thumbnail_allow_bucket]
}

# Create a CloudWatch log group for the Lambda function
resource "aws_cloudwatch_log_group" "thumbnail_cloudwatch" {
  name             = "/aws/lambda/${aws_lambda_function.thumbnail_lambda.function_name}"
  retention_in_days = var.log_group_retention_days
}

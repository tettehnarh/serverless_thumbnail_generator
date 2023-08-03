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


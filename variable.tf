# AWS region where resources will be deployed
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Name of the S3 bucket to store the original images
variable "original_image_bucket_name" {
  type    = string
  default = "leslie-original-image-bucket"
}

# Name of the S3 bucket to store the generated thumbnails
variable "thumbnail_image_bucket_name" {
  type    = string
  default = "leslie-thumbnail-image-bucket"
}

# Name of the Lambda function
variable "lambda_function_name" {
  type    = string
  default = "thumbnail_generation_lambda"
}

# Directory containing the Lambda function source code
variable "lambda_source_dir" {
  type    = string
  default = "src"
}

# Memory size (in MB) allocated to the Lambda function
variable "lambda_memory_size" {
  type    = number
  default = 256
}

# Number of days to retain CloudWatch logs for the Lambda function
variable "log_group_retention_days" {
  type    = number
  default = 30
}

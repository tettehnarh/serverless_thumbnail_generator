# Serverless thumbnail generator

This project leverages the magic of Terraform and Python to create a scalable and cost-effective solution for generating thumbnails from your images in the cloud.

## Overview

This is a serverless thumbnail generator project built with Terraform and Python. It sets up an AWS Lambda function triggered by S3 events to generate thumbnails for uploaded images using the Python Imaging Library (PIL). The generated thumbnails are then stored in a separate S3 bucket.

## Prerequisites

- Terraform installed on your local machine
- AWS account credentials configured on your local machine
- Python 3.x installed on your local machine

## Getting Started

1. Clone this repository to your local machine:

```bash
git clone https://github.com/tettehnarh/serverless_thumbnail_generator.git
cd serverless-thumbnail-generator
```

2. Update the variable.tf file:<br/>
   In the variables.tf file, set the appropriate values for the variables, such as aws_region, original_image_bucket_name, and thumbnail_image_bucket_name.
   These variables allow you to customize your infrastructure based on your requirements.

3. Deploy the infrastructure:<br/>
   Initialize Terraform and apply the configuration:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. Run command below to copy .jpg from your local disk to S3 bucket.<br/>

   ```bash
   aws s3 cp ~/Downloads/premium_photo.jpg s3://leslie-original-image-bucket
   ```

5. Run command below to view the cloudwatch logs
   ```bash
   aws logs tail /aws/lambda/thumbnail_generation_lambda
   ```

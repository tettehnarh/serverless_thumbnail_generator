import logging
import os
import boto3
from io import BytesIO
from PIL import Image

# Configure the logger to record information
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Log the incoming event and context information for monitoring purposes
    logger.info(f"event: {event}")
    logger.info(f"context: {context}")
    
    # Extract the source bucket name and object key (file path) from the S3 event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    # Set up the target bucket where the generated thumbnails will be stored (NB:Replace name with your own as S3 bucket name should be globally unique)
    thumbnail_bucket = 'leslie-thumbnail-image-bucket'
    
    # Extract the name and extension of the original image file
    thumbnail_name, thumbnail_ext = os.path.splitext(key)
    
    # Create the thumbnail key using the original filename with "-thumbnail" before the file extension
    thumbnail_key = f"{thumbnail_name}-thumbnail{thumbnail_ext}"

    # Create an S3 client to interact with AWS S3
    s3_client = boto3.client('s3')

    # Get the original image as a byte string from the source bucket
    file_byte_string = s3_client.get_object(Bucket=bucket, Key=key)['Body'].read()

    # Open the image using Python Imaging Library (PIL)
    img = Image.open(BytesIO(file_byte_string))

    # Log the size of the original image before compression
    logger.info(f"Size before compression: {img.size}")

    # Compress the image to a thumbnail size of 500x500 pixels using antialiasing
    img.thumbnail((500, 500), Image.ANTIALIAS)

    # Log the size of the image after compression
    logger.info(f"Size after compression: {img.size}")

    # Save the thumbnail image as a JPEG in memory
    buffer = BytesIO()
    img.save(buffer, "JPEG")
    buffer.seek(0)

    # Upload the thumbnail image to the target bucket
    s3_client.put_object(Bucket=thumbnail_bucket, Key=thumbnail_key, Body=buffer)

    # Return the original event to indicate successful processing
    return event

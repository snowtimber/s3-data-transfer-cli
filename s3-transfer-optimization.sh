#!/bin/bash

# cd into working directory
cd /Users/loganmey/dev/s3-data-transfer-cli

# run speedtest, install if necessary
# pip install speedtest-cli
speedtest-cli

# get folder size
# -s: Summarize and only show the total size for the given directory.
# -h: Show sizes in human-readable format (e.g., 1K, 234M, 2G).
# du -sh /path/to/directory
du -shk ./6way

# get file size
# -l: List in long format.
# -h: Show sizes in human-readable format.
# ls -lh /path/to/file
ls -lh ./6way/UNv1.0.6way.en

# AWS CLI Configuration
echo "Configuring AWS CLI..."
aws configure

# view existing configs
cat ~/.aws/credentials
cat ~/.aws/config

# clear out existing config settings
rm ~/.aws/config

# what AWS account are you in?
aws sts get-caller-identity

# list buckets
aws s3 ls

# list bucket contents
aws s3 ls s3://0-transfer-blog

#delete folder in bucket
aws s3 rm s3://0-transfer-blog/quip --recursive

# Compute sha256 checksum value for a file
echo "Calculating sha256 checksum..."
# openssl sha256 path/large_file.txt
openssl sha256 ./6way/UNv1.0.6way.en
# Alternatively
shasum -a 256 path/large_file.txt | cut -f1 -d' ' | xxd -r -p | base64

# Copy a single file to S3 for a test transfer and time the operation
echo "Testing file transfer to S3..."
# time aws s3 cp large_file.txt s3://mybucket/
time aws s3 cp ./6way/UNv1.0.6way.en s3://0-transfer-blog

# sync 
# aws s3 sync . s3://mybucket/
time aws s3 sync ./quip s3://0-transfer-blog/quip
time aws s3 sync ./100_10MB_files s3://0-transfer-blog/100_10MB_files

# S3 CLI Configuration Optimization
echo "Optimizing AWS CLI configuration..."
aws configure set default.s3.max_concurrent_requests 20
aws configure set default.s3.max_queue_size 10000
aws configure set default.s3.multipart_threshold 64MB
aws configure set default.s3.multipart_chunksize 16MB
aws configure set default.s3.max_bandwidth 100GB/s
aws configure set default.s3.payload_signing_enabled True

# Verify the modified configuration settings
echo "Verifying the configuration..."
cat ~/.aws/config

# Enable S3 Transfer Acceleration for a bucket
echo "Enabling S3 Transfer Acceleration..."
# aws s3api put-bucket-accelerate-configuration --bucket bucketname --accelerate-configuration Status=Enabled
aws s3api put-bucket-accelerate-configuration --bucket 0-transfer-blog --accelerate-configuration Status=Enabled

# Set configuration variable for the accelerate endpoint
echo "Setting accelerate endpoint..."
aws configure set default.s3.use_accelerate_endpoint true

# Sync entire local directory into Amazon S3 bucket and time the operation
echo "Syncing local directory to S3..."
time aws s3 sync . s3://mybucket/

# Check file integrity in S3 post-upload
echo "Checking file integrity in S3..."
# aws s3api head-object --bucket mybucket --key large_file.txt
aws s3api head-object --bucket 0-transfer-blog --key UNv1.0.6way.en

echo "Script completed."

# create X number of files of Y Size
for i in {1..100}; do
    dd if=/dev/urandom of=sample_file_$i bs=1M count=50
done

# creat 1 GB file
dd if=/dev/urandom of=1GB_file bs=1G count=1

#get bucket configuration
aws s3api get-bucket-notification-configuration --bucket 0-transfer-blog > notification.json


# permissions
aws lambda add-permission --function-name s3-sha256-eda  --action lambda:InvokeFunction --principal s3.amazonaws.com --source-arn arn:aws:s3:::$BUCKET_NAME --statement-id 1

# add bucket event trigger for sha256 lambda
aws s3api put-bucket-notification-configuration --bucket $BUCKET_NAME --notification-configuration notification.json

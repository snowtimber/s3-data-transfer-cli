# create X number of files of Y Size
for i in {1..100}; do
    dd if=/dev/urandom of=100_10MB_$i bs=10M count=1
done

# cd back to home directory
cd ..

# sha256 file integrity checksum
# SHA256(1GB_file)= 33e48510edadbcbf47882bbfe4542082e3b69df10b39849e40cc401ffabb20d6
# SHA256(100_10MB_files/100_10MB_100)= 2af3d162c588df36c8c505385bf95a1ff05808e7daf84aef8ef0859ded2e3b97
openssl sha256 100_10MB_files/100_10MB_100

# clear out existing config settings
rm ~/.aws/config

# set aws cli default region
aws configure

# view existing configs
cat ~/.aws/config

# set a bucket name
export BUCKET_NAME="0-0-upload-speed-test-bucket"

# create bucket
aws s3api create-bucket --bucket $BUCKET_NAME --region us-east-1

# time it takes to upload 1GB file
# aws s3 cp 1GB_file "s3://$BUCKET_NAME"  5.65s user 2.79s system 4% cpu 3:30.29 total
# aws s3 sync 100_10MB_files "s3://$BUCKET_NAME/100_10MB_files"  5.55s user 2.55s system 25% cpu 31.345 total
time aws s3 sync 100_10MB_files "s3://$BUCKET_NAME/100_10MB_files"

# add bucket event trigger for sha256 lambda

# optimizations
aws configure set default.s3.max_concurrent_requests 20
aws configure set default.s3.max_queue_size 1000
aws configure set default.s3.multipart_threshold 16MB
aws configure set default.s3.multipart_chunksize 16MB

# enable s3 transfer acceleration on bucket $.04/GB
aws s3api put-bucket-accelerate-configuration --bucket $BUCKET_NAME --accelerate-configuration Status=Enabled

# s3 transfer acceleration optimization ($.04/GB)
aws configure set default.s3.use_accelerate_endpoint true

# view existing configs
cat ~/.aws/config

# show files in s3 bucket
aws s3 ls "s3://$BUCKET_NAME"

#delete folder in bucket
aws s3 rm "s3://$BUCKET_NAME" --recursive

# time it takes to upload 1GB file with optimizations
# aws s3 cp 1GB_file "s3://$BUCKET_NAME"  6.29s user 3.07s system 4% cpu 3:30.83 total
# aws s3 sync 100_10MB_files "s3://$BUCKET_NAME/100_10MB_files"  6.73s user 6.13s system 86% cpu 14.841 total
time aws s3 sync 100_10MB_files "s3://$BUCKET_NAME/100_10MB_files"

# check sha256 file integrity checksum in lambda logs
# SHA256 Checksum for 0-upload-speed-test-bucket-prior/1GB_file: 33e48510edadbcbf47882bbfe4542082e3b69df10b39849e40cc401ffabb20d6

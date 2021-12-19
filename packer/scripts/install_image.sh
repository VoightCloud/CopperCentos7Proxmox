#!/bin/bash

#if [ -z $3 ]; then
#  echo "Usage: install_image.sh upload_file bucket_name desired_ami_name" && exit -1
#fi
#
#echo "Uploading $1"
#
#aws s3 cp builds/$1 s3://$2/infra/$1
#
#echo "Importing"
#import_id=`aws ec2 import-image --description "Bare Metal Built rhel-7.9-x86_64" --license-type BYOL \
#--disk-containers "Description=\"Bare Metal RHEL 7.9 x86_64\",Format=\"ova\",UserBucket={S3Bucket=\"$2\",S3Key=\"infra/$1\"}" | jq .ImportTaskId|tr -d /\"/`
#
#echo "ImportId: $import_id"
#
#while [ `aws ec2 describe-import-image-tasks --import-task-ids $import_id \
#| jq .ImportImageTasks[0].Status | tr -d /\"/` != "completed" ]; do
#  echo "Waiting for job $import_id to complete."
#  sleep 20
#done
#
#ami_id=`aws ec2 describe-import-image-tasks --import-task-ids $import_id \
#       | jq .ImportImageTasks[0].ImageId | tr -d /\"/`
#
#echo "Applying Name: $3 to $ami_id"
#
#aws ec2 copy-image --source-region us-gov-west-1 --source-image-id $ami_id --name $3
#aws ec2 deregister-image --image-id $ami_id
#
#while [ `aws ec2 describe-images --filters Name=name,Values=$3 \
#| jq .Images[0].State | tr -d /\"/` != "available" ]; do
#  echo "Waiting for $3 to become available"
#  sleep 20
#done

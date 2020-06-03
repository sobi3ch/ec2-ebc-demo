#!/bin/bash

REGION=$1
EC2_ID=$2

# Gather all volumes attached to the instance
echo $(aws ec2 describe-volumes  --region $REGION  \
  --filters Name=attachment.instance-id,Values=${EC2_ID}
            Name=attachment.device | jq -r '.Volumes[].Attachments[0] | select(.Device | contains("sda1") | not ) | .VolumeId') > detach.txt

for VOL_ID in $(cat detach.txt)
do
  aws ec2 detach-volume \
    --volume-id $VOL_ID
done

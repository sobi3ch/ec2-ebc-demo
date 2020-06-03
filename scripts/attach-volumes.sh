#!/bin/bash

EC2_ID=$1
AZ=$2
VOLUMES_NUMBER=$3
INSTANCE_NUMBER=$4

aws ec2 describe-volumes \
  --filters Name=tag:Name,Values=trans.eu \
            Name=status,Values=available \
            Name=availability-zone,Values=$AZ > volumes.json

# If we have any volumes then attach them
VOL_COUNT=$(jq -r '.Volumes | length' volumes.json)
COUNTER=67 # STARTS from g letter
if [[ $VOL_COUNT -gt 0 ]]
then
  for VOL_ID in $(jq -r '.Volumes[].VolumeId' volumes.json)
  do
    ((COUNTER=COUNTER+1))
    aws ec2 attach-volume \
      --volume-id $VOL_ID \
      --instance-id $EC2_ID \
      --device /dev/sd$(echo "$COUNTER" | xxd -p -r)
  done
fi

# # If less then volumes number then create & attache missing one
# if [[ $(jq -r '.Volumes | length' volumes.json) -lt $VOLUMES_NUMBER ]]
# then
#
# fi


# if there is no volumes then create them


# Clean on close
# rm volumes.json

#!/bin/bash

EC2_ID=$1
AZ=$2
VOLUMES_NUMBER=$3
INSTANCE_NUMBER=$4

aws ec2 detach-volume \
  --volume-id $EC2_ID

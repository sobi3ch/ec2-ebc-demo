#!/bin/bash

ID=$1

aws ec2 attach-volume \
  --volume-id vol-09a4293213888ce0c \
  --instance-id $ID \
  --device /dev/sdx

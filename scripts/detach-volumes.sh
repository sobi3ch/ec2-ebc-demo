#!/bin/bash

ID=$1

aws ec2 detach-volume \
  --volume-id vol-09a4293213888ce0c
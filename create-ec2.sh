#!/bin/bash

#"rabbitmq" "catalogue" "user"  "shipping" "payment" "dispatch" "web" "mysql"

NAMES=("mongodb" "cart")
DOMAIN_NAME=joindevops.fun
INSTANCE_TYPE=""
IMAGE_ID=ami-09c813fb71547fc4f
SECURITY_GROUP_ID=sg-0c82fa48dbc70749d 

for i in "${NAMES[@]}"; do
  if [[ $i == "mongodb" || $i == "mysql" ]]; then
    INSTANCE_TYPE="t3.micro"
  else
    INSTANCE_TYPE="t2.micro"
  fi
  echo "creating $i instance"
  aws ec2 run-instances --image-id $IMAGE_ID  --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID  --tag-specification "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"
# IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID  --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID  --tag-specification "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"  | jq -r '.Instances[0].PrivateIpAddress')
# echo " created $i instances: $IP_ADDRESS"


done
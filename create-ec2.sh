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

# Store the output of the 'aws ec2 run-instances' command
instance_info=$(aws ec2 run-instances --image-id "$IMAGE_ID" --instance-type "$INSTANCE_TYPE" --security-group-ids "$SECURITY_GROUP_ID" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]")

# Check if the EC2 instance creation was successful
if [ $? -eq 0 ]; then
  # Extract the private IP address from the instance creation output
  IP_ADDRESS=$(echo "$instance_info" | jq -r '.Instances[0].PrivateIpAddress')

  # Check if the IP address was successfully extracted
  if [ -z "$IP_ADDRESS" ]; then
    echo "Failed to retrieve private IP address for $i instance."
  else
    echo "Created $i instance: $IP_ADDRESS"
  fi
else
  echo "Failed to create $i instance."
fi

done
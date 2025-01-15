#!/bin/bash

# Disable pager for AWS CLI to avoid interactive prompts
export AWS_PAGER=""

# Define instance names and parameters
NAMES=$@
DOMAIN_NAME=joindevops.fun
INSTANCE_TYPE=""
IMAGE_ID="ami-09c813fb71547fc4f"
SECURITY_GROUP_ID=sg-0c82fa48dbc70749d
HOSTED_ZONE_ID=Z0798189H8VMAOYWAMIV

# Ensure AWS CLI is available by checking the PATH
export PATH=$PATH:/usr/local/bin  # Adjust if necessary

for i in $@; do
  # Set instance type based on name
  if [[ $i == "mongodb" || $i == "mysql" ]]; then
    INSTANCE_TYPE="t3.micro"
  else
    INSTANCE_TYPE="t2.micro"
  fi

  # Display instance creation details
  echo "creating $i instance type: $INSTANCE_TYPE"

  # Run AWS EC2 instance creation and store the Private IP address
  if command -v aws &> /dev/null; then
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specification "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    
    # Display the created instance's IP address
    echo "Created $i instance. Private IP address: $IP_ADDRESS"
  else
    echo "AWS CLI is not found in the PATH"
  fi
# route53 ka hosted zone dena hai
    # Add DNS record to Route53
    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch "$(cat <<EOF
{
  "Comment": "Add $i to Route53",
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "$i.$DOMAIN_NAME",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "$IP_ADDRESS"
          }
        ]
      }
    }
  ]
}
EOF
)"
    echo "DNS record for $i.$DOMAIN_NAME created successfully."
  else
    echo "AWS CLI is not found in the PATH"
  fi
done
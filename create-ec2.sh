# #!/bin/bash

# export AWS_PAGER=""
# NAMES=$@
# DOMAIN_NAME=joindevops.fun
# INSTANCE_TYPE=""
# IMAGE_ID="ami-09c813fb71547fc4f"
# SECURITY_GROUP_ID=sg-0c82fa48dbc70749d
# HOSTED_ZONE_ID=Z0798189H8VMAOYWAMIV
# export PATH=$PATH:/usr/local/bin  # Adjust if necessary

# for i in $@; do
#   if [[ $i == "mongodb" || $i == "mysql" ]]; then
#     INSTANCE_TYPE="t3.micro"
#   else
#     INSTANCE_TYPE="t2.micro"
#   fi

#   echo "Creating $i instance type: $INSTANCE_TYPE"

#   if command -v aws &> /dev/null; then
#     IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specification "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')

#     if [[ -z "$IP_ADDRESS" ]]; then
#       echo "Failed to create instance or fetch IP address for $i."
#       continue
#     fi

#     echo "Created $i instance. Private IP address: $IP_ADDRESS"

#     echo "Adding Route 53 record for $i.$DOMAIN_NAME with IP $IP_ADDRESS"
#     aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch "{
#       \"Comment\": \"Add record to Route53\",
#       \"Changes\": [
#         {
#           \"Action\": \"CREATE\",
#           \"ResourceRecordSet\": {
#             \"Name\": \"$i.$DOMAIN_NAME\",
#             \"Type\": \"A\",
#             \"TTL\": 300,
#             \"ResourceRecords\": [
#               {
#                 \"Value\": \"$IP_ADDRESS\"
#               }
#             ]
#           }
#         }
#       ]
#     }"
#   else
#     echo "AWS CLI is not found in the PATH"
#   fi
# done


#!/bin/bash

NAMES=$@
INSTANCE_TYPE=""
IMAGE_ID=ami-09c813fb71547fc4f
SECURITY_GROUP_ID=ssg-0c82fa48dbc70749d
DOMAIN_NAME=joindevops.fun
HOSTED_ZONE_ID=Z0798189H8VMAOYWAMIV

# if mysql or mongodb instance_type should be t3.medium , for all others it is t2.micro

for i in "${NAMES[@]}"
do  
    if [[ $i == "mongodb" || $i == "mysql" ]]
    then
        INSTANCE_TYPE="t3.medium"
    else
        INSTANCE_TYPE="t2.micro"
    fi
    echo "creating $i instance"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID  --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "created $i instance: $IP_ADDRESS"

    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '
    {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": "'$i.$DOMAIN_NAME'",
                            "Type": "A",
                            "TTL": 300,
                            "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
    }
    '
done
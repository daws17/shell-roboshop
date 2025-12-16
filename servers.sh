#!/bin /bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-00434aea2a5a1cc91"
ZONE_ID="Z001445138PJ8LEVGMQY"
DOMAIN_NAME="devops-practice.space"
for instance in $@
do

    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-00434aea2a5a1cc91 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query "Instances[0].InstanceId" --output text)

    if [ $instance != "frontend" ];then
         IP=$(aws ec2 describe-instances --instance-ids i-03a677ae88b0a425a --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
         RECORD_NAME="$INSTANCE.$DOMAIN_NAME"
    else
         IP=$(aws ec2 describe-instances --instance-ids i-03a677ae88b0a425a --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
         RECORD_NAME="$DOMAIN_NAME"
         
    fi

        echo "$instance: $IP"


        aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE-ID \
        --change-batch '
        {
             "Comment": "updating record set record set"
             ,"Changes": [{
             "Action"                 : "UPSERT"
            ,"ResourceRecordSet"      : {
                  "Name"              : "'$RECORD_NAME'"
                  ,"Type"             : "A"
                  ,"TTL"              : 1
                  ,"ResourceRecords"  : [{
                       "Value"        : "' $IP '"
              }]
           }
           }]
        }
        '
done 
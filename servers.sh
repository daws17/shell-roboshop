#!/bin /bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-00434aea2a5a1cc91"

for instance in $@
do

    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-sg-00434aea2a5a1cc91 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query "Instances[0].InstanceId" --output text)

    if [ $instance != "frontend" ]; then
         IP=$(aws ec2 describe-instances --instance-id -i-03a677ae88b0a425a --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
         IP=$(aws ec2 describe-instances --instance-id -i-03a677ae88b0a425a --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
         
    fi

    echo "$instance: $IP"

done 
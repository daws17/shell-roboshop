#!/bin/bash

set -euo pipefail

trap 'echo "there is error in $LINENO, command is: $BASH_COMMAND"' ERR

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
MONGODB_HOST="devops-practice.space"
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "script started executed at : $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: please run the script with root privilage"
    exit 1
fi



dnf module disable nodejs -y &>> $LOG_FILE

dnf module enable nodejs:20 -y &>> $LOG_FILE

dnf install nodejs -y &>> $LOG_FILE

id roboshop
if [ $? -ne 0 ]; then &>> $LOG_FILE
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
else
    echo -e "user already exit ....$Y SKIPPING $N"
fi

mkdir -p /app

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>> $LOG_FILE

cd /app

rm -rf /app/*

unzip /tmp/user.zip &>> $LOG_FILE

npm install &>> $LOG_FILE

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service

systemctl daemon-reload
systemctl enable user &>> $LOG_FILE

systemctl restart user

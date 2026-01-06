#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
MONGODB_HOST="mongodb.devops-practice.space"
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "script started executed at : $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: please run the script with root privilage"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2....$R FAILURE $N"| tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2....$G SUCCESS $N"| tee -a $LOG_FILE
    fi
}

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "enabling nodejs 20"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "installing nodejs 20"

id roboshop
if [ $? -ne 0 ]; then &>> $LOG_FILE
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
    VALIDATE $? "creating system user"
else
    echo -e "user already exit ....$Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOG_FILE
VALIDATE $? "downloding catalogue applications" 

cd /app
VALIDATE $? "changing to app directory"

rm -rf /app/*
VALIDATE $? "removing existing code"

unzip /tmp/catalogue.zip &>> $LOG_FILE
VALIDATE $? "unzip catalogue"
 
npm install &>> $LOG_FILE
VALIDATE $? "installing dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copy systemctl services" 

systemctl daemon-reload
systemctl enable catalogue &>> $LOG_FILE
VALIDATE $? "enable catalogue" 

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copy mongo repo" 

dnf install mongodb-mongosh -y &>> $LOG_FILE
VALIDATE $? "install mongoDB clint" 

mongosh --host $MONGODB_HOST </app/db/master-data.js &>> $LOG_FILE
VALIDATE $? "load catalogue products"

systemctl start catalogue
VALIDATE $? "restarted catalogue services"


#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "script started executed at : $(date)" | tee -a $LOG_FILE

IF [ $USERID -ne 0 ]; then
    echo "ERROR:: please run the script with root privilage"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "installing $2....$R FAILURE $N"| tee -a $LOG_FILE
        exit 1
    else
        echo -e "installing $2....$G SUCCESS $N"| tee -a $LOG_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "adding mongo repo"

dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? "installing mongoDB"

systemctl enable mongod &>> $LOG_FILE
VALIDATE $? "enable mongoDB"

systemctl start mongod
VALIDATE $? "start mongoDB"
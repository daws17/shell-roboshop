#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER
SCRIPT_DIR=$PWD
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

CP $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $LOG_FILE
VALIDATE $? "adding rabbitmq repo"

dnf install rabbitmq-server -y &>> $LOG_FILE
VALIDATE $? "installing rabbitmq server"

systemctl enable rabbitmq-server &>> $LOG_FILE
VALIDATE $? "enabling rabbitmq server"

systemctl start rabbitmq-server &>> $LOG_FILE
VALIDATE $? "starting rabbitmq server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOG_FILE
VALIDATE $? "adding user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG_FILE
VALIDATE $? "setting permissions"

END_TIME=$(date +%s)
TOTAL_TIME=$(( END_TIME - START_TIME ))
echo -e "script executed in : $Y $TOTAL_TIME seconds $N"
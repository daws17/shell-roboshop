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


dnf module disable redis -y &>> $LOG_FILE
VALIDATE $? "disabling redis"

dnf module enable redis:7 -y &>> $LOG_FILE
VALIDATE $? "enabling redis 7"

dnf install redis -y &>> $LOG_FILE
VALIDATE $? "installing redis 7" 

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no /etc/redis/redis.conf
VALIDATE $? "allowing remote connections to redis"

systemctl enable redis &>> $LOG_FILE
VALIDATE $? "Enable redis"

systemctl start redis &>> $LOG_FILE
VALIDATE $? "starting redis"
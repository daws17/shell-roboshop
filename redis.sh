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
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER
echo "script started executed at : $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: please run the script with root privilage"
    exit 1
fi




dnf module disable redis -y &>> $LOG_FILE


dnf module enable redis:7 -y &>> $LOG_FILE


dnf install redis -y &>> $LOG_FILE


sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf


systemctl enable redis &>> $LOG_FILE


systemctl start redis &>> $LOG_FILE



END_TIME=$(date +%s)
TOTAL_TIME=$(( END_TIME - START_TIME ))
echo -e "script executed in : $Y $TOTAL_TIME seconds $N"
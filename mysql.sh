#!/bin/bash

userid=$(id -u)
logs_folder="/var/log/shell-script"
logs_file="$logs_folder/$0.log"
R="\e[31m"
G="\e[32m"
N="\e[0m"


mkdir -p $logs_folder

if [ $userid -ne 0 ]; then
   echo -e "$R please run the script with root user access $N" |tee -a $logs_file
   exit 1
fi

validate(){
    if [ $1 -ne 0 ]; then
      echo -e "$2 is..........$R failed $N" |tee -a $logs_file
      exit 1
    else
      echo -e "$2 is...........$G success $N" |tee -a $logs_file
    fi
}

dnf install mysql-server -y &>>$logs_file
validate $? "installing mysql"

systemctl enable mysqld &>>$logs_file
systemctl start mysqld
validate $? "eanble and start mysql"

rm -rf ExpenseApp@1

mysql_secure_installation --set-root-pass ExpenseApp@1 #setting the password for root user
validate $? "setting root password"



#!/bin/bash

userid=$(id -u)
logs_folder="/var/log/shell-script"
logs_file="$logs_folder/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
script_dir=$PWD
mysql_host=mysql.jarugula.online

mkdir -p $logs_folder

if [ $userid -ne 0 ]; then
  echo -e "$R please run the script with root user access $N" |tee -a $logs_file
  exit 1
fi

validate(){
    if [ $1 -ne 0 ]; then
      echo -e "$2 is.......$R failed $N" |tee -a $logs_file
      exit 1
    else
      echo -e "$2 is......$G success $N" |tee -a $logs_file
    fi
}

dnf module disable nodejs -y &>>$logs_file
validate $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$logs_file
validate $? "enabling nodejs 20 version"

dnf install nodejs -y &>>$logs_file
validate $? "installing nodejs"

id expense  &>>$logs_file            #if you run script first user will create if you run again them it will show user exists
if [ $? -ne 0 ]; then
  useradd expense
  validate $? "creating system expense user"
else
  echo -e "user already exists......$Y skipping $N"
fi

mkdir -p /app &>>$logs_file
validate $? "creating app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

curl -o /tmp/backend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
validate $? "downloading backend code"

cd /app
validate $? "moving to app directory"

unzip /tmp/backend.zip &>>$logs_file
validate $? "unzipping the backend code"

npm install &>>$logs_file
validate $? "installing dependencies"

cp $script_dir/backend.service /etc/systemd/system/backend.service
validate $? "creating systemctl services"

systemctl daemon-reload &>>$logs_file
systemctl enable backend
systemctl start backend
validate $? "enabling and start backend"

dnf install mysql -y &>>$logs_file
validate $? "installing mysql"

mysql -h $mysql_host -uroot -pExpenseApp@1 < /app/schema/backend.sql
validate $? "loading data"

systemctl restart backend &>>$logs_file
validate $? "resarting backend"






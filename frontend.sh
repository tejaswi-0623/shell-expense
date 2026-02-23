#!/bin/bash

userid=$(id -u)
logs_folder="/var/log/shell-script"
logs_file="$logs_folder/$0.log"
R="\e[31m"
G="\e[32m"
N="\e[0m"
script_dir=$PWD

mkdir -p $logs_folder

if [ $userid -ne 0 ]; then
   echo -e "$R please run the script with root user access $N" |tee -a $logs_file
   exit 1
fi

validate(){
    if [ $1 -ne 0 ]; then
      echo -e "$2 is.........$R failed $N" |tee -a $logs_file
      exit 1
    else
      echo -e "$2 is........$G success $N" |tee -a $logs_file
    fi
}

dnf install nginx -y &>>$logs_file
validate $? "installing nginx"

systemctl enable nginx &>>$logs_file
systemctl start nginx
validate $? "enable and start nginx"

rm -rf /usr/share/nginx/html/*
validate $? "remove default content"

curl -o /tmp/frontend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
validate $? "downloading frontend content"

cd /usr/share/nginx/html
validate $? "moving to nginx html folder"

unzip /tmp/frontend.zip &>>$logs_file
validate $? "unzipping the frontend code"

rm -rf /etc/nginx/nginx/default.d/expense.conf 

cp $script_dir/expense.conf /etc/nginx/default.d/expense.conf &>>$logs_file
validate $? "creating nginx config file"

systemctl restart nginx &>>$logs_file
validate $? "restarting nginx"
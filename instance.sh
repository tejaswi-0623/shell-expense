#!/bin/bash

sg_id="sg-09de3392916ee8cce"
ami_id="ami-0220d79f3f480ecf5"

for instance in $@
do
  instance_id=$(aws ec2 run-instances \
          --image-id $ami_id \
          --instance-type "t3.micro" \
          --security-group-ids $sg_id \
          --tag-specifications "RescourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
          --query 'Instances[0].InstanceId' \
          --output text)
    
   if [ $instance == "frontend" ]; then
       IP_address=$(aws ec2 describe-instances \
               --instance-ids $instance_ids \
               --query 'Reservations[].Instances[].PublicIpAddress' \
               --output text)
         record_name="expense.$domain_name"
    else 
       IP_address=$(aws ec2 describe-instances \
               --instance-ids $instance_id \
               --query 'Reservations[].Instance[].PrivateIpAddress' \
               --output text)
        record_name="$instance.$domain_name" #instancename.jarugula.online
    fi
      echo "IP address is $IP_address"
done
    
  
#!/bin/bash
# This script is meant to be run in the User Data of an EC2 Instance while it's booting. 
set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# The variables below are filled in using Terraform interpolation
echo "${instance_text}" > index.html
sudo apt-get update
#nohup busybox httpd -f -p "${instance_port}" &
apt install awscli -y
aws s3 cp --recursive s3://amirco99-bucket  / --region eu-west-2
sudo apt-get -y install nginx
sudo service nginx start
#export HOSTNAME=$(curl -s http://169.254.169.254/latest/metadata/hostname)
#export $PUBLIC_IPV$=$(curl -s curl http://169.254.169.254/latest/meta-data/public-ipv4)
#echo Hi from AWS $HOSTNAME, with IP Address: $PUBLIC_IPV > /var/www/html/indexx.nginx.html



# AWS-ELB


Create a terraform script that will start EC2  servers  in AWS.

Each AZ will run one server.

The server should be a Linux server with NGINX (basic configuration), with simple index.html. 

The server will take the index.html from s3 and copy it in to the created server.

All servers will be conected to load balancing. 

Setup auto scaling group with CPU Utilization threshold of 70% CPU. 

Monitoring this server/service

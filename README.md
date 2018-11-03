# CreditFi
Homework assignment

The exercise is to create a script that will start a server (spot and non-spot) in AWS.

The server should be a Linux server with NGINX (basic configuration), with simple index.html. 
The html should have your name
The server will take the index.html from s3 and copy it in to the created server

Setup auto scaling group to this server with 40% CPU
Find a solution for monitoring this server/service

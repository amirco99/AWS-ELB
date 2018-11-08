#!/bin/bash

cd  s3
terraform apply
sleep 180
cd ..
terraform apply

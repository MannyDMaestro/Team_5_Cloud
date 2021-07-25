!/bin/sh

# Author: Sumanth
# What does this script do: It launches an ec2 instance in my aws account 

aws ec2 run-instances --image-id ami-05c974bfb54bf90f6 --count 1 --instance-type t2.medium --key-name minecraft --security-groups-ids sg-09ec07707a5bc0b87 --region us-west-1


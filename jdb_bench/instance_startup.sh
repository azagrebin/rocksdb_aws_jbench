#!/usr/bin/env bash

INT="${INT:-nvme1n1}"
EBS="${EBS:-sdf}"
EFS="${EFS:-fs-7b874102}"
EFSIO="${EFSIO:-fs-5caf6925}"

# internal store
sudo mkfs -t ext4 /dev/${INT}
sudo mkdir -p /internal
sudo mount /dev/${INT} /internal
sudo chown -R ec2-user:ec2-user /internal

# ebs store
sudo mkdir -p /ebs
sudo mount /dev/${EBS} /ebs
sudo chown -R ec2-user:ec2-user /ebs

# efs store, do not forget 3b in https://docs.aws.amazon.com/efs/latest/ug/accessing-fs-create-security-groups.html
sudo mkdir -p /efs
sudo mkdir -p /efsio
sudo mount -t efs -o tls,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${EFS}:/ /efs
sudo mount -t efs -o tls,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${EFSIO}:/ /efsio
sudo chown -R ec2-user:ec2-user /efs
sudo chown -R ec2-user:ec2-user /efsio

export JAVA_HOME=/usr/java/default

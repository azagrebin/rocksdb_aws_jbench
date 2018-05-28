#!/usr/bin/env bash

id=$1
iid=$2
pem="${pem:-rocksdb_test.pem}"
dev="${dev:-/dev/sdf}"

function state {
    aws ec2 describe-volumes --volume-id ${id} --query 'Volumes[0].State' --output text
}

function instance {
    aws ec2 describe-volumes --volume-id ${id} --query 'Volumes[0].Attachments[0].InstanceId' --output text
}

function ip {
    instance_id=$1
    aws ec2 describe-instances --instance-id ${instance_id} --query 'Reservations[0].Instances[0].PublicIpAddress' --output text
}

function run_ssh {
    instance_id=$1
    cmd=$2
    instance_ip=`ip ${instance_id}`
    echo "run '${cmd}' in ${instance_id} (${instance_ip})"
    ssh -i "${pem}" ec2-user@${instance_ip} ${cmd}
}

echo 'umount ebs'
run_ssh `instance` 'sudo umount /ebs'

echo 'detach ebs'
aws ec2 detach-volume --volume-id ${id}

while [[ `state` == 'in-use' ]]
do
    echo 'wait detach...'
done

echo 'attach ebs'
aws ec2 attach-volume --volume-id ${id} --instance-id ${iid} --device ${dev}

while [[ `state` != 'in-use' ]]
do
    echo 'wait attach...'
    sleep 0.1
done

echo 'mount ebs'
run_ssh ${iid} "sudo mkdir -p /ebs; sudo mount ${dev} /ebs"
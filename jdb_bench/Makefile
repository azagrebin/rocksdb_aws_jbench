cwd = $(shell pwd)

db ?= $(cwd)/db

rocksdb ?= ../../rocksdb

row_num ?= 10000000
read_num ?= 1000000
write_per_sec ?= 10000
thread_num ?= 1
disable_wal ?= false

key_size ?= 16
val_size ?= 800

cache_size ?= -1

max_open_files ?= $(shell ulimit -n)

ec2_templ ?= $(shell cat ./ec2_template.json | tr '\n' ' ')

pem ?= rocksdb_test.pem

virtual_memory_limit_bytes ?= 7000000 # about 7 GB

dev ?= /dev/sdf

ebs_type ?= io1 # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html
ebs_size ?= 100
ebs_iops ?= 1000
ebs_zone ?= us-east-2a

args ?=

name ?= rdbpti

jbench_path ?= ~/rocksdb_aws_jbench/jdb_bench

build:
	$(MAKE) -C $(rocksdb) jdb_bench

run:
	mkdir -p $(db)/wal
	ulimit -v $(virtual_memory_limit_bytes)
	cd $(rocksdb)/java; \
	db=$(db) \
	jdb_bench=./jdb_bench.sh \
	num=$(row_num) \
	r=$(read_num) \
	t=$(thread_num) \
	wps=$(write_per_sec) \
	ks=$(key_size) \
	vs=$(val_size) \
	cs=$(cache_size) \
	of=$(max_open_files) \
	dwal=$(disable_wal) \
	$(cwd)/$(scr).sh; \
	cd $(cwd)
	du -sh $(db)

bulk_load:
	scr=bulk_load $(MAKE) run

readwhilewriting: clean
	scr=bulk_load $(MAKE) run
	scr=readwhilewriting $(MAKE) run

readwhilewriting_internal:
	db=/internal/db $(MAKE) readwhilewriting

readwhilewriting_ebs:
	db=/ebs/db $(MAKE) readwhilewriting

readwhilewriting_efs:
	db=/efs/db $(MAKE) readwhilewriting

readwhilewriting_efsio:
	db=/efsio/db $(MAKE) readwhilewriting

clean:
	@mkdir -p $(db)/wal
	@du -sh $(db)
	rm -rf $(db)/*

get_template_from_existing_instance:
	aws ec2 get-launch-template-data --instance-id $(id)

create_template:
	aws ec2 create-launch-template \
         --launch-template-name RocksDbPerfTestTempl \
         --launch-template-data '$(ec2_templ)'

list_templates:
	aws ec2 describe-launch-templates

delete_template:
	aws ec2 delete-launch-template --launch-template-id $(id)

run_from_template:
	aws ec2 run-instances \
		--launch-template LaunchTemplateId=$(id) \
		--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$(name)}]' \
		--user-data file://instance_launch.sh

list_instances:
	aws ec2 describe-instances \
		--query 'Reservations[*].Instances[*].{ID:InstanceId,AMI:ImageId,STATE:State.Name,NAME:Tags[?Key==`Name`]|[0].Value,IP:PublicIpAddress,PRIVATE_IP:PrivateIpAddress}' \
		--filters Name=instance-state-name,Values=pending,running,shutting-down,stopping,stopped \
		--output table

#--query 'Reservations[*].Instances[*].{ID:InstanceId,AMI:ImageId,STATE:State.Name,T0:Tags[0].Value,T1:Tags[1].Value}' \

start_instance:
	aws ec2 start-instances --instance-ids $(id)

stop_instance:
	aws ec2 stop-instances --instance-ids $(id)

terminate_instance:
	aws ec2 terminate-instances --instance-ids $(id)

create_volume:
	aws ec2 create-volume \
		--availability-zone $(ebs_zone) \
		--size $(ebs_size) \
		--volume-type $(ebs_type) \
		--iops $(ebs_iops) \
		--tag-specifications 'ResourceType=volume,Tags=[{Key=RocksDbPerfTest,Value=true}]'

list_volumes:
	aws ec2 describe-volumes \
		--query 'Volumes[*].{ZONE:AvailabilityZone,TYPE:VolumeType,ID:VolumeId,STATE:State,SIZE:Size,IOPS:Iops,INSTANCE:Attachments[0].InstanceId,DEVICE:Attachments[0].Device}' \
		--output table

attach_volume:
	aws ec2 attach-volume --volume-id $(id) --instance-id $(iid) --device $(dev) $(args)

detach_volume:
	aws ec2 detach-volume --volume-id $(id) $(args)

switch_volume:
	pem=$(pem) dev=$(dev) time ./switch_volume.sh $(id) $(iid)

delete_volume:
	aws ec2 delete-volume --volume-id $(id)

instance_query_by_name:
	@aws ec2 describe-instances \
		--query 'Reservations[*].Instances[*].$(query)' \
		--filters \
			Name=tag:Name,Values=$(name) \
			Name=instance-state-name,Values=pending,running,shutting-down,stopping,stopped \
		--output text

ssh:
	$(eval ip ?= $(shell make instance_query_by_name query=PublicIpAddress name=$(name)))
	ssh -i "$(pem)" ec2-user@$(ip) -t "cd $(jbench_path); bash -l"

mount_instance:
	$(eval ip ?= $(shell make instance_query_by_name query=PublicIpAddress name=$(name)))
	mkdir -p ec2instance
	ssh-add -K $(pem)
	sshfs ec2-user@$(ip):/home/ec2-user ec2instance

umount_instance:
	diskutil umount ec2instance

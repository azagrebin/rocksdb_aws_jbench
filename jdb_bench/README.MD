# AWS Storage RocksDB benchmarking

Original benchmarks are described [here](https://rocksdb.org.cn/doc/RocksJava-Performance-on-Flash-Storage.html).
These benchmarks use provided by rocksdb `rocksdb/java/jdb_bench.sh` utility.

Clone rocksdb and set `rocksdb` var in `Makefile` to its location.
```bash
git clone https://github.com/facebook/rocksdb.git
```

## Setup in AWS

- create AWS account, web console user name and password (ask administrator)

- [install](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) and 
[setup](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration) aws cli 
(might require creating cli access key/secret)

- create [pem file](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) for ssh access
and download it into rocksdb/java/jbenchmark/rocksdb_test.pem

- install [sshfs](https://github.com/osxfuse/osxfuse/wiki/SSHFS) if you want to mount ec2 home dir locally

- create iops provisioned [ebs volume](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-creating-volume.html) or manage [in web console](https://console.aws.amazon.com/ec2/v2/home#Volumes:sort=desc:createTime)
```bash
make create_volume
make list_volumes
```

- create general and multi i/o [efs](https://aws.amazon.com/getting-started/tutorials/create-network-file-system) 
and check its network [security rule](https://docs.aws.amazon.com/efs/latest/ug/accessing-fs-create-security-groups.html) (step 3b)

- create an instance template or manage [in web console](https://console.aws.amazon.com/ec2/v2/home#LaunchTemplates:sort=launchTemplateId)
```bash
make create_template list_templates
```

- spin up one or more test instances from template or manage [in web console](https://console.aws.amazon.com/ec2/v2/home#Instances:sort=statusChecks)
```bash
make run_from_template id=<template_id> name=<instance_name>
make list_instances
```

- attach ebs volume to instance
```bash
make list_instances
make list_volumes
make attach_volume id=<volume_id> iid=<instance_id>
```

- ssh into instance
```bash
make list_instances
make ssh name=<instance_name>
# or 
make ssh ip=<public_instance_ip>
```

## Setup benchmark

### After instance launch

- clone repo
```bash
git clone https://github.com/azagrebin/rocksdb_aws_jbench.git
cd rocksdb
git checkout ebs
```

- download last version of rocksdb jar
```bash
cd java
mkdir -p target
cd target
wget http://central.maven.org/maven2/org/rocksdb/rocksdbjni/5.11.3/rocksdbjni-5.11.3.jar
cd ../jbenchmark
```

- set correct instance internal store device name in rocksdb/java/jbenchmark/instance_startup.sh
```bash
lsblk
```

- set correct efs id in rocksdb/java/jbenchmark/instance_startup.sh

- format ebs if its first use (might also need correct device name if there are more of them)
```bash
sudo mkfs -t ext4 /dev/sdf
```

- build benchmark
```bash
make build
```

- continue to `After instance restart` section

### After instance restart

```bash
cd <rocksdb_path>/rocksdb/java/jbenchmark
./instance_startup.sh
```

## Merge ebs switch between instances

```bash
make list_volumes
make list_instances
make switch_volume id=<volume id> iid=<target instance id>
```

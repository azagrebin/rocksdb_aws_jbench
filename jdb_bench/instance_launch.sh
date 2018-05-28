#!/usr/bin/env bash

#tools
sudo yum install -y htop
sudo yum install -y amazon-efs-utils
sudo yum install -y git

# deps
sudo yum install -y gcc-c++

git clone https://github.com/gflags/gflags.git
cd gflags
git checkout v2.0
./configure && make && sudo make install
cd ..

sudo yum install -y devtoolset-3
sudo yum install -y snappy snappy-devel
sudo yum install -y zlib zlib-devel
sudo yum install -y bzip2 bzip2-devel
sudo yum install -y lz4-devel
sudo yum install -y libasan

wget https://github.com/facebook/zstd/archive/v1.1.3.tar.gz
mv v1.1.3.tar.gz zstd-1.1.3.tar.gz
tar zxvf zstd-1.1.3.tar.gz
cd zstd-1.1.3
make && sudo make install
cd ..

# java
sudo yum remove -y java-1.7.0
sudo wget --no-cookies --header "Cookie: gpw_e24=xxx; oraclelicense=accept-securebackup-cookie;" \
    http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.rpm
sudo rpm -ivh jdk-8u171-linux-x64.rpm
sudo rm -rf jdk-8u171-linux-x64.rpm
export JAVA_HOME=/usr/java/default

# increase max number of open files
sudo bash -c 'echo "*        hard nofile 500000" >> /etc/security/limits.conf'
sudo bash -c 'echo "*        soft nofile 500000" >> /etc/security/limits.conf'

# git config
cat >~/.gitconfig <<EOL
[alias]
	lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
	up = "!git remote update -p; git merge --ff-only @{u}"
	ci = commit
	co = checkout
	st = status
	br = branch -a
	sb = show-branch
	sbs = show-branch --sha1-name
	acp = "!git add -u; git ci; git push"
[push]
	default = simple
[credential]
	helper = store
EOL
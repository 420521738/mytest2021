#!/bin/bash
#===============================================================================
#
#          FILE: install_docker.sh
# 
#         USAGE: sh install_docker.sh
# 
#   DESCRIPTION: 用于安装docker环境
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#  ORGANIZATION: 
#       CREATED: 2020.03.24
#      REVISION: 1.0
#===============================================================================
yum install -y yum-utils device-mapper-persistent-data lvm2 nfs-utils  conntrack-tools
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast
yum install -y docker-ce   docker-ce-cli
systemctl daemon-reload 
systemctl enable docker
systemctl restart docker
systemctl status docker
docker info |grep Version

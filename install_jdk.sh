#!/bin/bash
#===============================================================================
#
#          FILE: install_jdk.sh
# 
#         USAGE: ./install_jdk.sh
# 
#   DESCRIPTION: 用于安装jdk1.8
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#  ORGANIZATION: qinzhi
#       CREATED: 2020.03.16
#      REVISION:  ---
#===============================================================================

#解压安装包
cd /root/soft/
tar xf jdk.tgz -C /usr/local/

#添加jdk环境变量
cat >> /etc/profile <<'EOF'

#JAVE ENV
export JAVA_HOME=/usr/local/jdk
export PATH=$JAVA_HOME/bin:$PATH
EOF

#使配置生效
source /etc/profile

#验证
java -version


#!/bin/bash
#===============================================================================
#
#          FILE: ./install_finderweb.sh
# 
#         USAGE: ./install_finderweb.sh 
# 
#   DESCRIPTION: 用于安装finderweb客户端，日志收集系统
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#  ORGANIZATION: 
#       CREATED: 2020.03.16
#      REVISION: 1.0
#===============================================================================


# 创建tomcat用户，提前安装好jdk
useradd tomcat

# 解压findeweb包
cd /root/soft
tar xf finderweb.tar.gz -C /usr/local/

# 修改主属
chown -R tomcat:tomcat /usr/local/finderweb/

# 启动
su - tomcat -c "/usr/local/finderweb/bin/startup.sh"

## 加到开机自启动/etc/rc.local
cat >> /etc/rc.local <<EOF

# finderweb 8885
su - tomcat -c "/usr/local/finderweb/bin/startup.sh"
EOF

#!/bin/bash
#===============================================================================
#
#          FILE: init.sh
# 
#         USAGE: ./init.sh  主机名 主机密码 
# 
#   DESCRIPTION: 用于新机器的环境初始化
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#  ORGANIZATION: 
#       CREATED: 2020.03.16
#      REVISION: 1.0
#===============================================================================

# 1.修改ssh默认端口
sed -i  's/#Port 22/Port 22612/' /etc/ssh/sshd_config
# 2.修改主机名
hostName=$1
pass=$2
hostnamectl set-hostname $hostName
# 3.安装基础软件
yum -y install vim lsof zip strace openssl openssl-devel gcc gcc-c++ cmake bind-utils libxml2-devel net-tools sysstat ntpdate curl telnet lbzip2 bzip2 bzip2-devel pcre pcre-devel zlib-devel python-devel lrzsz man unzip git wget
# 4.修改history记录
sed -i "/TMOUT/d"  /etc/profile
sed -i 's/HISTSIZE=1000/HISTSIZE=3000/g' /etc/profile
echo 'export HISTTIMEFORMAT="`whoami` : %F %T : "' >> /etc/profile
source /etc/profile
# 5.添加定时同步时间任务
echo "* * * * * /usr/sbin/ntpdate ntp1.aliyun.com" >> /var/spool/cron/root
# 6.修改默认dns为阿里dns
sed -i '2i\nameserver 223.5.5.5' /etc/resolv.conf
sed -i '3i\nameserver 223.6.6.6' /etc/resolv.conf
chattr +i /etc/resolv.conf
# 7.限制数修改
cat >> /etc/security/limits.conf <<EOF
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
EOF
# 8.防火墙设置
iptables -F
systemctl stop firewalld
systemctl disable firewalld
yum install -y iptables
yum -y update iptables 
yum -y install iptables-services
iptables -P INPUT ACCEPT
iptables -F
iptables -X
iptables -Z
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 22612 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -m state --state  RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -s 10.5.28.0/24 -p all -j ACCEPT
iptables -A INPUT -s 10.5.29.0/24 -p all -j ACCEPT
iptables -A INPUT -s 10.10.27.199/32 -p all -j ACCEPT
iptables -A INPUT -s 10.186.140.0/24 -p all -j ACCEPT
iptables -A INPUT -s 10.186.141.0/24 -p all -j ACCEPT
iptables -A INPUT -s 10.5.28.39 -p all -j ACCEPT
iptables -A INPUT -s 10.5.28.45 -p tcp --dport 8885 -j ACCEPT

iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP
service iptables save
systemctl enable iptables.service
systemctl start iptables.service
# 9.添加目录
mkdir /opt/utopa/{service,config,logs} -p
mkdir /opt/shell
mkdir /root/soft
# 10.内核参数优化
cat > /etc/sysctl.conf << EOF
fs.file-max = 999999
kernel.sysrq = 0
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 30
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
EOF
# 11.添加普通用用户
useradd utopaos
echo utopaos@123123 | passwd --stdin utopaos
# 12.修改root密码
echo $pass | passwd --stdin root
# 13.添加跳板机用户
useradd jump
mkdir /home/jump/.ssh/
sed -i 's/^%wheel.*/#&/' /etc/sudoers
echo "jump    ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3Yhq2mYOCrCVbqLn1Dy34j8kgWb9IEihyxgAe0CCcBaV+8i+vNKWumppnF205MbzbxFmFyWECUiXtNVRaeoD6xNTfP+SL8BI0qLh7Z4XorWd9aDHFcVIsPI8n0vLOtCEczyskOYvXGApVNM//RnbrbyxIXEiA1+ejOJA0xs9B9vUEzN1BLCRvlYe24rQx34+JktS/lyiRzkQijto2wqWohX6Jnj/TEMbyFuLBFRHX69xVvn5N3iUkFp+6JeAKPE1UT3rtMN9odiQmCiesmnMysuVfPzDBfsQVBdB7R4dHEIk2okOzfGTQLaQbDRMwkzH9vSWKycUa38G87HlWujQN root@tool02" >> /home/jump/.ssh/authorized_keys
chown jump.jump -R  /home/jump/.ssh/
chown jump.jump -R /home/jump/
chmod 700 /home/jump/.ssh/
chmod 600 /home/jump/.ssh/authorized_keys
# 14关闭selinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# 15 修改时区
timedatectl  set-timezone Asia/Shanghai

#!/bin/bash
#Title:ssh_auth.sh
#Usage:����Ҫ���õ�ipд�뵽�ű�����Ŀ¼��ip.list�ļ��С���Ҫ���д������ļ���
#Description:���ö��������
#Author:�ֺ�
#Date:2016-05-12
#Version:1.0
for ip in `cat ip.list`
do
#=======================================================
#��ÿ̨���������ɹ�Կ�ļ�id_rsa.pub
expect <<EOF &>/dev/null  
spawn ssh $ip ssh-keygen
expect  {
		"*yes/no*" {exp_send "yes\r";exp_continue}
		"*password:" {exp_send "root123\r";exp_continue}
		"id_rsa):" {exp_send "\r";exp_continue}
		"passphrase):" {exp_send "\r";exp_continue}
		"again:" {exp_send "\r";exp_continue}
		"*y/n)?" {exp_send "y\r";exp_continue}
		}
#interact
#expect eof
EOF
#=========================================================       
    for ip2 in `cat ip.list`
        do
#=========================================================
#����Կ�ļ�׷�ӵ�������������֤�ļ��У�
#ȱ�㣺Ҳ��׷�ӵ��Լ�����֤�ļ��С�
expect <<EOF &>/dev/null
spawn ssh $ip -t ssh-copy-id -i ~/.ssh/id_rsa.pub $ip2
expect {
                "*yes/no*" {exp_send "yes\r";exp_continue}
                "*password:" {exp_send "root123\r";exp_continue}
}
EOF
		done
done
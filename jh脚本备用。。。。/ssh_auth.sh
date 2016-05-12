#!/bin/bash
#Title:ssh_auth.sh
#Usage:将需要配置的ip写入到脚本所在目录的ip.list文件中。需要自行创建此文件。
#Description:配置多机器互信
#Author:贾寒
#Date:2016-05-12
#Version:1.0
for ip in `cat ip.list`
do
#=======================================================
#在每台机器上生成公钥文件id_rsa.pub
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
#将公钥文件追加到其他机器的认证文件中，
#缺点：也会追加到自己的认证文件中。
expect <<EOF &>/dev/null
spawn ssh $ip -t ssh-copy-id -i ~/.ssh/id_rsa.pub $ip2
expect {
                "*yes/no*" {exp_send "yes\r";exp_continue}
                "*password:" {exp_send "root123\r";exp_continue}
}
EOF
		done
done
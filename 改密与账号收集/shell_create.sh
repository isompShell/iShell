#!/bin/bash
#Title:shell_create.sh
#Usage: document
#Description:auto create shell
#Author:jiahan
#Date:2016-11-09
#Version:1.0

#脚本名：cisco.sh
#标识：  改密
#资源类型: network
#命令：>en|#$su_pass|#conf t|#username $username password $password |#linie vty 0 4

#==================================================
#函数1：识别配置文件(structure)
#==================================================
structure(){ 
  #count=`sed -n '$=' $config_file`   #统计配置文件行数,加入判断是否有空行
  #(`awk -F: '{print $2}'`)           #配置文件内容
  #cat -A config_file.txt | tail -n1
  config_file="config_file.txt"
  cat $config_file | uniq >$config_file  #将多空白行合并为一行
  space_num=(`egrep -n "^$" $config_file | awk -F":" '{print $1}'`)  #空白行的行号
  space_count=`echo ${space_num[@]} | awk -F[\ ] '{print NF}'`     #空白行的数量
  

  #sed -i s/.$// $config_file
  file_name=`sed -n '1p' $config_file` #要生成的脚本名
  ltc=`sed -n '2p' $config_file`
  resource=`sed -n '3p' $config_file`
  #symbol=(`sed -n '4p' $config_file`)
  #count=`echo ${symbol[@]}|awk -F[\ ] '{print NF}'`
}

#==================================================
#函数2：windows改密(win_change_password)
#================================================== 


#==============================================
#函数3：linux改密(linux_change_password)
#==============================================


#==============================================
#函数4：network改密(net_change_password)
#==============================================
net_change_password(){
echo $file_name
cat > $file_name <<EOF
#!/bin/bash

if [ \$# -eq 6 ];then
	PROTOCOL=\$1  #远程登录协议 ssh or telnet:超时时间
	USER=\$2      #管理员用户
	IP=\$3        #交换机IP
	PWD=\$4  	  #管理员密码
	username=\$5  #要更改的用户名
	password=\$6  #要更改的用户密码
	
fi

if [ \$# -eq 7 ];then
	PROTOCOL=\$1  #远程登录协议 ssh or telnet:超时时间
	USER=\$2      #管理员用户
	IP=\$3        #交换机IP
	PWD=\$4  	  #管理员密码
	username=\$7  #要更改的用户名
	password=\$5  #要更改的用户密码
	SECRET=\$6	  #特权密码
fi
PROTOCOL=\`echo \$PROTOCOL | awk -F: '{print \$1}'\` 
TIMEOUT=\`echo \$PROTOCOL | awk -F: '{print \$2}'\`  #超时时间

case \$PROTOCOL in
    ssh)
        CMD="ssh -o StrictHostKeyChecking=no -o CheckHostIP=no \${USER}@\${IP}"
    ;;
    telnet)
        CMD="telnet \${IP}"
    ;;
esac
expect <<EOF
set timeout \$TIMEOUT
spawn \$CMD
expect  "sername:" 
send "\$USER\r"
expect "Password:"
send "\$PWD\r"
EOF

#for (( i = 1; i <=$count; i++ )); do
#	command=`sed -n '5p' $config_file | awk -v c="$i" -F"|" '{print $c}'`
#cat >> $file_name <<EOF
#expect "*${symbol[i-1]}"
#send "$command\r"
#EOF
#done

for (( i = 0; i < $space_count-1; i++ )); do
  	let temp=${space_num[$i]}+2         #空行下2行为命令行
  	let temp1=${space_num[$i+1]}-1      #空行上一行为命令行
  	#let count=${space_num[$i+1]}-${space_num[$i]}-2 #命令的行数
  	#symbol=(`sed -n "$temp,${temp1}p" $config_file | awk -F"|" '{print $1}'`) #截取到的第一位标识.如：> : # #
  	#command=(`sed -n "$temp,${temp1}p" $config_file | awk -F"|" '{print $2}'`) #截取到的标识后命令
  	#let count=$temp1-$temp         #标识数量
  	for (( i = $temp; i <=$temp1; i++ )); do
  		symbol=`sed -n "${i}p" $config_file | awk -F"|" '{print $1}'`
  		command=`sed -n "${i}p" $config_file | awk -F"|" '{print $2}'`
cat >> $file_name <<EOF
expect "$symbol"
send "$command\r"
EOF
done
done


cat >> $file_name <<EEE
send "exit\r"   
send "quit\r"
send "exit\r"   
send "quit\r" 
expect eof
EOF
EEE

}  

#==============================================
#函数5：windows账号收集(win_user_collect)
#==============================================


#==============================================
#函数6：linux账号收集(linux_user_collect)
#==============================================


#==============================================
#函数7：network账号收集(network_user_collect)
#==============================================


#==============================================
#函数8：windows添加账号(win_add_user)
#==============================================


#==============================================
#函数9：linux添加账号(linux_add_user)
#==============================================


#==============================================
#函数10：network添加账号(network_add_user)
#==============================================


#==============================================
#函数11：配置文件错误提示(config_error)
#==============================================
config_error(){
	echo "配置文件错误"
	exit 0
}

Main(){
  structure
  if [[ $ltc=="改密" ]]; then
  	echo $ltc
  	case $resource in
  		windows*)
        	win_change_password
  			;;
  	      linux*)
			linux_change_password
  			;;
  		network*)
			net_change_password
  			;;
  		default)
			config_error
  			;;
  	esac
  elif [[ $ltc=="账号收集" ]]; then
  	case $resource in
  		windows* )
			win_user_collect
  			;;
  	      linux* )
			linux_user_collect
  			;;
  		network* )
			net_user_collect
  			;;
  		default)
			config_error
  			;;
  	esac
  elif [[ $ltc=="添加账号" ]]; then
  	case $resource in
  		windows* )
			win_add_user
  			;;
  	      linux* )
			linux_add_user
  			;;
  		network*)
			network_add_user
  			;;
  		default)
			config_error
  			;;
  	esac
  else
  	config_error
  	exit 0
  fi
}
Main

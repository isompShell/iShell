#!/bin/bash
#Title:chang_network.sh
#Usage:
#Description:change password | change username | change super_password
#Author:jiahan
#Date:2016-10-12
#Version:1.0
#========================
old_user="tnt1"
old_pass="123456"
new_pass="123456" #
telnet_ip="telnet 192.168.100.2"
su_pass="huaweiquit" #原提权密码
#变量是用来干什么的
#========================

h3c(){
    expect <<EOF
       set timeout 5
       #spawn $telnet_ip
       #expect  "Username:" 
       #send "$old_user\r"
       #expect "Password:"
       #send "$old_pass\r"
       #expect "*>" 
       #send "su\r"
       #expect "Password:" 
       #send "$su_pass\r"
       #expect "*>" 
       #send "sys\r"
       #expect "*]"
       #send "local-user $old_user\r"
       #expect "*$old_user]"
       #send "password cipher $new_pass\r"
       #send "quit\r"
       #send "quit\r"
       #expect "*>" 
       #send "quit\r"
        
        spawn $telnet_ip
	expect  "Username:" 
	send "$old_user\r"
	expect "Password:"
	send "$old_pass\r"
	expect "*>" 
	send "su\r"
	expect "Password:" 
	send "$su_pass\r"
        expect "*>" 
        send "sys\r"
	expect "*]"
	send "super password level 3 cipher $new_pass\r"
	send "quit\r"
	send "quit\r"
	expect "*>"
	send "quit\r"
EOF
}

Cisco(){
    expect <<EOF
    	set timeout 5
       #spawn $telnet_ip
       #expect "Username:"
       #send "$old_user\r"
       #expect "Password:"
       #send "$old_pass\r"
       #expect "*>"
       #send "en\r"
       #expect "Password:"
       #send "$su_pass\r"
       #expect "*#"
       #send "conf t\r"
       #expect "*(config)#"
       #send "username $old_user password $new_pass\r"
       #send "line vty 0 4\r"
       #expect "*(config-line)"
       #send "login local\r"
       #send "exit\r"
       #expect "*(config)#"
       #send "exit\r"
       #expect "*#"
       #send "exit\r"


        spawn $telnet_ip
	expect "Username:"
	send "$old_user\r"
	expect "Password:"
	send "$old_pass\r"
	expect "*>"
	send "en\r"
	expect "Password:"
	send "$su_pass\r"
	expect "*#"
	send "conf t\r"
	expect "*(config)#"
	send "enable secret $new_pass\r"
	send "exit\r"
	send "exit\r"
	send "exit\r"
EOF
}

Huawei(){
    expect <<EOF
    	set timeout 5
        #spawn $telnet_ip
	#expect "Username:"
	#send "$old_user\r"
	#expect "Password:"
	#send "$old_pass\r"
	#expect "*>"
	#send "su\r"
	#expect "Password:"
        #send "$su_pass\r"
	#send "sys\r"
	#expect "*]"
	#send "aaa\r"
	#expect "*aaa]"
	#send "local-user $old_user password cipher $new_pass\r"
	#send "local-user $old_user service-type telnet\r"
	#send "local-user $old_user privilege level 3\r"
	#send "user-interface vty 0 4\r"
	#send "authentication-mode aaa\r"
	#expect "*vty0-4]"
	#send "quit\r"
	#expect "*]"
	#send "quit\r"
	#expect "*>"
	#send "quit\r"


        spawn $telnet_ip
	expect "Username:"
	send "$old_user\r"
	expect "Password:"
	send "$old_pass\r"
	expect "*>"
	send "su\r"
	expect "Password:"
        send "$su_pass\r"
	send "sys\r"
	expect "*]"
	send "super password level 3 cipher $new_pass\r"
	send "quit\r"
	expect "*>"
	send "quit\r"
EOF
}
Main(){
   Huawei

}


Main;

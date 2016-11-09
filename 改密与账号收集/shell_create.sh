#!/bin/bash
#Title:shell_create.sh
#Usage: document
#Description:easy
#Author:jiahan
#Date:2016-11-09
#Version:1.0

1、将配置文件的每一行都赋值变量；
2、使用if判断变量的值

#==================================================
#函数1：识别配置文件(structure)
#==================================================


#==================================================
#函数2：windows改密(win_change_password)
#================================================== 


#==============================================
#函数3：linux改密(linux_change_password)
#==============================================


#==============================================
#函数4：network改密(net_change_password)
#==============================================


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

Main(){
  if [[ =="改密" ]]; then
  	case 类型 in
  		windows )
        	win_change_password
  			;;
  	      linux )
			linux_change_password
  			;;
  		network )
			net_change_password
  			;;
  		default)
			config_error
  			;;
  	esac
  elif [[ =="账号收集" ]]; then
  	case 类型 in
  		windows )
			win_user_collect
  			;;
  	      linux )
			linux_user_collect
  			;;
  		network )
			net_user_collect
  			;;
  		default)
			config_error
  			;;
  	esac
  elif [[ =="添加账号" ]]; then
  	case 类型 in
  		windows )
			win_add_user
  			;;
  	      linux )
			linux_add_user
  			;;
  		network )
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

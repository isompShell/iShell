#!/binbash
#Title:auto_keepalived_config.sh
#Usage:  交互式
#Description: 
#Author:jiahan
#Date:2016-08-04
#Version:1.0

#===============================
#安装lvs+keepalived
#===============================
#
#
#
OPTION=$(whiptail --title "fort dialog" --menu "Choose your option" 15 60 4 \
"1" "lvs+keepalived" \
"2" "heartbeat" \
"3" "sersync" \
 3>&1 1>&2 2>&3)
if [[ $OPTION -eq 1 ]]; then

elif [[ $OPTION -eq 2 ]]; then
        #statements
elif [[ $OPTION -eq 3 ]]; then
        #statements
fi

function keepalived_dialog(){
        keepdia=$(whiptail --title "fort dialog" --menu "Choose your option" 15 60 4 \
        "1" "自动" \
        "2" "检测" \
        "3" "安装" \
        "4" "配置" \
         3>&1 1>&2 2>&3)
         if [[ $keepdia -eq 1 ]]; then
                 keepalived_install
         fi
}

function keepalived_install(){

}


#===============================
#修改keepalived配置文件
#===============================
function keepalived_config(){
echo "============lvs+keepalived autoconfig=============="
read -p "Enter host state? [master/backup1/backup2]:"  state
read -p "Enter interface? [eth0]:" interface
read -p "Enter priority :" priority
read -p "Enter virtual IP :" vip
read -p "Enter real_server :" real_server
real_server=($real_server) #real_server数组
#real_server_count=echo $real_server | awk '{print NF}'   #real_serverIP数量


cat > /etc/keepalived/keepalived.conf <<EOF
! Configuration File for keepalived
global_defs {
router_id LVS_1
}
vrrp_instance VI_1 {
        state $state
        interface $interface
        virtual_router_id 60
        priority $priority
        advert_int 1
        authentication {
                auth_type PASS
                auth_pass 1111
        }
        virtual_ipaddress {
                $vip
        }
}
virtual_server $vip 443 {
        delay_loop 6
        lb_algo sh
        lb_kind DR
        # persistence_timeout 60
        protocol TCP
        real_server ${real_server[0]} 443 {
                notify_up /usr/local/bin/sh/tomcat_up.sh
                notify_down /usr/local/bin/sh/tomcat_down_master.sh
                TCP_CHECK {
                        connect_timeout 10
                        nb_get_retry 3
                        delay_before_retry 3
                        connect_port 443
                }
        }
        real_server ${real_server[1]} 443 {
                notify_up /usr/local/bin/sh/tomcat_up.sh
                notify_down /usr/local/bin/sh/tomcat_down_backup1.sh
                TCP_CHECK {
                        connect_timeout 10
                        nb_get_retry 3
                        delay_before_retry 3
                        connect_port 443
                }
        }
        real_server ${real_server[2]} 443 {
                notify_up /usr/local/bin/sh/tomcat_up.sh
                notify_down /usr/local/bin/sh/tomcat_down_backup2.sh
                TCP_CHECK {
                        connect_timeout 10
                        nb_get_retry 3
                        delay_before_retry 3
                        connect_port 443
                }
}
}
virtual_server $vip 22 {
        delay_loop 6
        lb_algo sh
        lb_kind DR
        # persistence_timeout 60
        protocol TCP
        real_server ${real_server[0]} 22 {                                           
                TCP_CHECK {                                                       
                        connect_timeout 10                                        
                        nb_get_retry 3                                            
                        delay_before_retry 3                                      
                        connect_port 22                                           
                }                                                                 
        }                                                                                                                                                         
        real_server ${real_server[1]} 22 {                                           
                TCP_CHECK {                                                       
                        connect_timeout 10                                        
                        nb_get_retry 3                                            
                        delay_before_retry 3                                      
                        connect_port 22                                           
                }                                                                 
        }                                                                         
        real_server ${real_server[2]} 22 {                                           
                TCP_CHECK {                                                       
                        connect_timeout 10                                        
                        nb_get_retry 3                                            
                        delay_before_retry 3                                      
                        connect_port 22                                           
                }                                                                 
        }                                                                         
}                                                                                                                                                                                                                                                                                                                                       
virtual_server $vip 3390 {                                              
        delay_loop 6                                                              
        lb_algo sh                                                                
        lb_kind DR                                                                
        # persistence_timeout 60                                                  
        protocol TCP                                                              
        real_server ${real_server[0]} 3390 {                                         
                TCP_CHECK {                                                       
                        connect_timeout 10                                        
                        nb_get_retry 3                                            
                        delay_before_retry 3                                      
                        connect_port 3390                                         
                }                                                                 
        }                                                                                                                                                         
        real_server ${real_server[1]} 3390 {                                         
                TCP_CHECK {                                                       
                        connect_timeout 10                                        
                        nb_get_retry 3                                            
                        delay_before_retry 3                                      
                        connect_port 3390                                         
                }                                                                 
        }                                                                         
        real_server ${real_server[2]} 3390 {                                         
                TCP_CHECK {                                                       
                        connect_timeout 10                                        
                        nb_get_retry 3                                            
                        delay_before_retry 3                                      
                        connect_port 3390                                         
                }                                                                 
        }                                                                         
}
virtual_server $vip 20021 {     
        delay_loop 6                                                              
        lb_algo sh                                                                
        lb_kind DR                                                                
        # persistence_timeout 60                                                  
        protocol TCP                                                              
        real_server ${real_server[0]} 20021 {                                         
                TCP_CHECK {                                                       
                        connect_timeout 10                                        
                        nb_get_retry 3                                            
                        delay_before_retry 3                                      
                        connect_port 20021                                      
                }                                                                 
        }                                                                                                                                                         
        real_server ${real_server[1]} 20021 {                                         
                TCP_CHECK {                                                       
                        connect_timeout 10                                        
                        nb_get_retry 3                                            
                        delay_before_retry 3                                      
                        connect_port 20021                                         
                }                                                                 
        }                                                                         
        real_server ${real_server[2]} 20021 {                                         
                TCP_CHECK {                                                       
                        connect_timeout 10                                        
                        nb_get_retry 3                                            
                        delay_before_retry 3                                      
                        connect_port 20021                                      
                }                                                                 
        }                                                                                                                                                         
}
EOF
｝
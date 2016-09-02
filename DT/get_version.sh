#!/bin/bash
num=`tail -1 /var/lib/fort/version.sn`
version=`head -1 /var/lib/fort/version.sn`
echo $num
#PA=`awk -F: /PA/'{print $2}' /var/lib/fort/control_$version`
#echo $PA
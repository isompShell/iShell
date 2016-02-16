#!/bin/bash
DATE=`date +"%Y%m%d"`
IF_Disk=`smartctl -i /dev/sda|grep SMART|grep "does not"`
MegaCli=`MegaCli64 -PDList -aALL > $DATE.log`
First_M=`awk '/Slot Number: 0/{while(getline)if($0!~/PD Type/)print;else exit}'  $DATE.log > $DATE.first.log`
Second_M=`awk '/Slot Number: 1/{while(getline)if($0!~/PD Type/)print;else exit}'  $DATE.log > $DATE.second.log`
Third_M=`awk '/Slot Number: 2/{while(getline)if($0!~/PD Type/)print;else exit}'  $DATE.log > $DATE.third.log`
Fourth_M=`awk '/Slot Number: 3/{while(getline)if($0!~/PD Type/)print;else exit}' $DATE.log > $DATE.fourth.log`
First_Media=`cat $DATE.first.log|grep "Media Error Count"|awk -F" " '{print $4}'`
Second_Media=`cat $DATE.second.log|grep "Media Error Count"|awk -F" " '{print $4}'`
Third_Media=`cat $DATE.third.log|grep "Media Error Count"|awk -F" " '{print $4}'`
Fourth_Media=`cat $DATE.fourth.log|grep "Media Error Count"|awk -F" " '{print $4}'`
First_Other=`cat $DATE.first.log|grep "Other Error Count"|awk -F" " '{print $4}'`
Second_Other=`cat $DATE.second.log|grep "Other Error Count"|awk -F" " '{print $4}'`
Third_Other=`cat $DATE.third.log|grep "Other Error Count"|awk -F" " '{print $4}'`
Fourth_Other=`cat $DATE.fourth.log|grep "Other Error Count"|awk -F" " '{print $4}'`
S_Disk=`smartctl -H /dev/sda|grep SMART|tail -n1|awk -F" " '{print $6}'`
#F_Disk=`MegaCli64 -AdpAllInfo -aALL |grep  "Physical Devices"|awk -F" " '{print $4}'`
F_Disk=`cat /usr/local/bin/sh/h_disk.conf`
if [ ! -n "${IF_Disk}"  ];then


   if [ "${S_Disk}" = "PASSED" ];then
echo "0,,0,,Disk is health"
else
echo "0,,1,,Disk possibly damaged,please replace"
fi


else

if [ "${F_Disk}" = 4 ];then
#if [ -s "{$DATE.first.log}" ];then echo "0 disk is health";else echo "0 disk do not exist,please check";fi
if [ ! -n "${First_Media}" ];then echo "0,,3,,disk do not exist,please check"
else 
if [ "${First_Media}" -gt 0 ];then echo "0,,1,,disk possibly damaged,please replace"
else
if [ "${First_Other}" -gt 0 ];then echo "0,,2,,disk may be loose, please debug";else echo "0,,0,,disk is health";fi;fi;fi


if [ ! -n "${Second_Media}" ];then echo "1,,3,,disk do not exist,please check"
else 
if [ "${Second_Media}" -gt 0 ];then echo "1,,1,,disk possibly damaged,please replace"
else
if [ "${Second_Other}" -gt 0 ];then echo "1,,2,,disk may be loose, please debug";else echo "1,,0,,disk is health";fi;fi;fi


if [ ! -n "${Third_Media}" ];then echo "2,,3,,disk do not exist,please check"
else 
if [ "${Third_Media}" -gt 0 ];then echo "2,,1,,disk possibly damaged,please replace"
else
if [ "${Third_Other}" -gt 0 ];then echo "2,,2,,disk may be loose, please debug";else echo "2,,0,,disk is health";fi;fi;fi



if [ ! -n "${Fourth_Media}" ];then echo "3,,3,,disk do not exist,please check"
else 
if [ "${Fourth_Media}" -gt 0 ];then echo "3,,1,,disk possibly damaged,please replace"
else
if [ "${Fourth_Other}" -gt 0 ];then echo "3,,2,,disk may be loose, please debug";else echo "3,,0,,disk is health";fi;fi;fi

rm -rf $DATE.log
rm -rf $DATE.first.log
rm -rf $DATE.second.log
rm -rf $DATE.third.log
rm -rf $DATE.fourth.log




else


if [ ! -n "${First_Media}" ];then echo "0,,3,,disk do not exist,please check"
else 
if [ "${First_Media}" -gt 0 ];then echo "0,,1,,disk possibly damaged,please replace"
else
if [ "${First_Other}" -gt 0 ];then echo "0,,2,,disk may be loose, please debug";else echo "0,,0,,disk is health";fi;fi;fi


if [ ! -n "${Second_Media}" ];then echo "1,,3,,disk do not exist,please check"
else 
if [ "${Second_Media}" -gt 0 ];then echo "1,,1,,disk possibly damaged,please replace"
else
if [ "${Second_Other}" -gt 0 ];then echo "1,,2,,disk may be loose, please debug";else echo "1,,0,,disk is health";fi;fi;fi



rm -rf $DATE.log
rm -rf $DATE.first.log
rm -rf $DATE.second.log
rm -rf $DATE.third.log
rm -rf $DATE.fourth.log


fi
fi

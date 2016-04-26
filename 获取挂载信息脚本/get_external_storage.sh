#!/bin/bash 

ISdir=/dev/disk/by-path
ISdir1=(`ls -l ${ISdir} |egrep "iscsi" |awk '{print $NF}'|sed -r 's/((\.+)\/)+/\/dev\//'`)
ISdir2=(`mount |awk '{print $1}'|egrep "^(/dev/[sh]|(((\/\/)?([1-2]?[0-9]?[0-9])).?))+"`) 
l=0
result="";
temp="";
for i in ${ISdir2[@]};do

	for j in ${ISdir1[@]};do
		if test "$i" == "$j" ;then
			let ++l
			ISdisk=${i:4} #;echo $IP
			IP=`ls -l ${ISdir}|egrep ".*${ISdisk}$"|sed -r 's/.*ip-//;s/:3.*//'`
			NAME=`ls -l ${ISdir}|egrep ".*${ISdisk}$"|sed -r 's/.*-l/l/;s/.->.*//'`
			DIR=(`mount |egrep "${i}" |awk '{print $1" "$3}'`)
			temp=$"{\"auditStorageExtendType\":\"iscsi\",\"distalIp\":\"${IP}\",\"iscsiName\":\"${NAME}\",\"localPath\":\"${DIR[1]}\",\"newDisk\":\"${DIR[0]}\"},"	
			result=$result$temp;
		fi
	done

	if  mount |egrep ${i}|egrep "\\\\" >/dev/null;then			
		Wname=`mount|egrep "$i"|sed 's/^.*username=//;s/,uid.*//'`
		RDIR=(`mount |egrep "$i"|sed 's/[/]/ /g'|awk '{print "/"$2}'`)
		LOCALPATH=`mount|egrep "$i"|awk '{print $3}'`
		IP=`mount|egrep "$i"|sed 's/^.*addr=//;s/,file.*//'`
		temp=$"{\"auditStorageExtendType\":\"windows\",\"distalIp\":\"${IP}\",\"distalPath\":\"${RDIR}\",\"localPath\":\"${LOCALPATH}\",\"distalAccount\":\"${Wname}\"},"
               result=$result$temp;                 
        fi
		
	if mount |egrep ${i}|egrep "nfs" >/dev/null;then
		 Lname=(`mount |egrep "$i"|sed 's/[=:]/ /g'|awk '{print $2" "$4" "$NF" "}'|sed 's/)//g'`)
             	temp=$"{\"auditStorageExtendType\":\"linux\",\"distalIp\":\"${Lname[2]}\",\"distalPath\":\"${Lname[0]}\",\"localPath\":\"${Lname[1]}\",\"distalAccount\":\"--\"},"
		result=$result$temp;
	fi
done

if  [ -n "$result" ] ;then
 result=$(echo $result |sed -r 's/,$//g') 
echo "["$result"]";
fi 

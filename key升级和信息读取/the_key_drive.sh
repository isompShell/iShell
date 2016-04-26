#!/bin/bash 
#-----------------------------------------------------------------
#Filename:	the_key_drive.sh
#Revision:	1.1
#Date:		2015/06/27
#Author:	Brice
#Description:	The key of query and update.
#Notes: 	If you want to upgrade key, it is necessary to 
#		specify a key at the back of the script file.
#		Case:
#		    the_key_drive.sh 071D255908260315.RyArmUdp
#-----------------------------------------------------------------

#Global Declarations
FILENAME="${1}"
KEY="$(SimpShell -lic)"

#Sanity checks
#To detect the key exists
if [[ "${KEY}" = *enum*eor* ]] ;then
	echo "Didn't find the key."
	exit 1
fi
	
#The main body

#To determine whether a parameter.
if [ -z "${FILENAME}" ];then
	echo "${KEY}"
	exit 0
else 
	#To determine whether a file exists.
	if [ -e "${FILENAME}" ];then 
		cd /usr/local/bin/lic.d
		ECHO=$(./lic_update "${FILENAME}")

			#Determine whether to upgrade success.
			if [[ "${ECHO}" = *update*eor* ]];then
				echo "File is repeated use."
				exit 3
			else 
			echo "Upgrade success."
			exit 0
			fi		
	else 
		echo "File does not exist."
		exit 2
	fi
	
fi
exit 0
#END

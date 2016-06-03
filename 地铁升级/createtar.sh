#!/bin/bash

P_VERSION="0x4c92"
Package="fort-service"
MASTER_VERSION="1.0.1"
#有多少目录就添加多少TARFILE
TARFILE1="/usr/local/fort"
TARFILE2=""
TARFILE3=""
function tar_all()
{
      tar -zcvPf ${P_VERSION}.${Package}.${MASTER_VERSION}.tar.gz ${TARFILE1}
}

#dir_tmp=/root/
#sed -n -e '1,/^exit 0$/!p' $0 > "${dir_tmp}/${P_VERSION}.${Package}.${MASTER_VERSION}.tar.gz" 2>/dev/null 
#cd $dir_tmp
tar_all

exit 0

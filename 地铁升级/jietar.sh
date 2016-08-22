#!/bin/bash
echo "1.0.0" >/var/lib/fort/version.sn
bash 0x4D01-fort-service.isomp.1.0.1.64
echo "1.0.1" >/var/lib/fort/version.sn
bash 0x4D01-fort-service.isomp.1.0.2.64
echo "1.0.2" >/var/lib/fort/version.sn
bash 0x4D01-fort-service.isomp.1.0.3.64
echo "1.0.3" >/var/lib/fort/version.sn
bash 0x4D01-fort-service.isomp.1.0.4.64
echo "1.0.4" >/var/lib/fort/version.sn
bash 0x4D01-fort-service.isomp.1.0.5.64
echo "1.0.5" >/var/lib/fort/version.sn
bash 0x4D01-fort-service.isomp.1.0.6.64
echo "1.0.6" >/var/lib/fort/version.sn
bash 0x4D01-fort-service.isomp.1.0.7.64
echo "1.0.7" >/var/lib/fort/version.sn
bash 0x4D01-fort-service.isomp.1.0.8.64
echo "1.0.8" >/var/lib/fort/version.sn
bash 0x4D01-fort-service.isomp.1.0.9.64
echo "1.0.9" >/var/lib/fort/version.sn
bash 0x4D01-fort-service.isomp.1.0.10.64
echo "1.0.10" >/var/lib/fort/version.sn
bash 0x4D01-fort-service.isomp.1.0.11.64
echo "1.0.11" >/var/lib/fort/version.sn
for((i=1;i<12;i++))
do
	cat extracttar.sh /root/0x4D01-fort-service.1.0.$i.tar.gz >0x4D01-fort-service.isomp.1.0.$i.64
done
	

#!/bin/bash
kee="/etc/init.d/keepalived restart"
for i in `cat /etc/ip`
do
	ssh $i $kee
done

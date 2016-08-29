#!/bin/bash
<<<<<<< HEAD
kee="/etc/init.d/keepalived restart"
for i in `cat /etc/ip`
do
	ssh $i $kee
done
=======
/etc/init.d/keepalived restart
>>>>>>> b70105f0a714d080b4987f46a67e0faf4ac984a4

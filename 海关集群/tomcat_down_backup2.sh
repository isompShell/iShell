#!/bin/bash
<<<<<<< HEAD
ipvsadm -d -t 192.168.23.100:443 -r 192.168.23.103:443
ipvsadm -d -t 192.168.23.100:22 -r 192.168.23.103:22
ipvsadm -d -t 192.168.23.100:3390 -r 192.168.23.103:3390
ipvsadm -d -t 192.168.23.100:20021 -r 192.168.23.103:20021
=======
ipvsadm -d -t 192.168.200.59:443 -r 192.168.200.52:443
ipvsadm -d -t 192.168.200.59:22 -r 192.168.200.52:22
ipvsadm -d -t 192.168.200.59:3390 -r 192.168.200.52:3390
ipvsadm -d -t 192.168.200.59:20021 -r 192.168.200.52:20021
>>>>>>> b70105f0a714d080b4987f46a67e0faf4ac984a4

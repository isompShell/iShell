#!/bin/bash
ipvsadm -d -t 192.168.23.100:443 -r 192.168.23.67:443
ipvsadm -d -t 192.168.23.100:22 -r 192.168.23.67:22
ipvsadm -d -t 192.168.23.100:3390 -r 192.168.23.67:3390
ipvsadm -d -t 192.168.23.100:20021 -r 192.168.23.67:20021
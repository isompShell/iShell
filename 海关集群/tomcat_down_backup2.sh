#!/bin/bash
ipvsadm -d -t 192.168.200.59:443 -r 192.168.200.52:443
ipvsadm -d -t 192.168.200.59:22 -r 192.168.200.52:22
ipvsadm -d -t 192.168.200.59:3390 -r 192.168.200.52:3390
ipvsadm -d -t 192.168.200.59:20021 -r 192.168.200.52:20021

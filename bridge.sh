#!/bin/bash

##
## Bridge Script 
## 
ifconfig eth0 down
ifconfig eth1 down
ifconfig br0 down
brctl addbr br0
brctl addif br0 eth0 eth1
brctl show


ifconfig eth0 0.0.0.0 up
ifconfig eth1 0.0.0.0 up

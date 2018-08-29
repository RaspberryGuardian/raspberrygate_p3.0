#!/bin/bash

TARGET=eth1
EHTERNET=$(ifconfig | grep $TARGET | awk '{print $1}')


##
## Bridge Script 
##

if [ wlan0$EHTERNET == wlan0 ] ; then
    ## WiFi start
    TARGET=wlan0
    /etc/init.d/hostapd start
fi


ifconfig eth0 down
ifconfig $TARGET down
ifconfig br0 down
brctl addbr br0
brctl addif br0 eth0 $TARGET
brctl show


ifconfig eth0 0.0.0.0 up
ifconfig $TARGET 0.0.0.0 up

exit 0

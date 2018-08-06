#!/bin/bash

if [ -d /opt/raspg ] ; then
    echo "Update raspg utils"
else
    echo "Making /opt/raspg directory"
    if [ -d  /opt ] ; then
	mkdir /opt/raspg 
	echo '/opt/raspg directory is created'
	mkdir /opt/raspg/bin
	mkdir /opt/raspg/lib
	mkdir /opt/raspg/etc
    else
	echo 'Raspberry Pi/ Rasbian ????'
	exit 0
    fi
fi

if [ ! -x /usr/bin/bc ] ; then
    apt-get install bc
fi
if [ ! -x /sbin/brctl ] ; then
    apt-get install bridge-utils
fi

if  [ ! -x  /usr/sbin/udhcpd ] ; then
    apt-get install udhcpd
fi


if [ -f udhcpd.conf.org ] ; then
    echo  ""
else
    echo  "First installed and backup original udhcpd.conf"
    mv /etc/udhcpd.conf /etc/udhcpd.conf.org
fi

echo "Renew udhcpd.conf"
cp udhcpd-raspg.conf /etc/udhcpd.conf

install bridge.sh /opt/raspg/bin
install router-nat.sh /opt/raspg/bin
install config-update.sh /opt/raspg/bin


if [ -f /opt/raspg/bin/config-update.sh ] ; then
    echo 'Copy raspg into /etc/init.d/'
    install raspg_initd /etc/init.d/raspg

    ## Sometime command insserv is not found.
    if  [  -x  /usr/sbin/update-rc.d ] ; then
	## old fashion
	/usr/sbin/update-rc.d raspg defaults
    else
	## newer style
	/usr/sbin/insserv raspg
    fi

else
    echo 'Install Error... 1'
    exit 1
fi

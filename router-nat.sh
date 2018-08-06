#!/bin/bash

RASPGDIR=/opt/raspg
ifconfig eth0 down
ifconfig eth1 down

modprobe iptable_nat
echo 1 > /proc/sys/net/ipv4/ip_forward

#
# Check raspg.conf
#

if [ -f $RASPGDIR/etc/raspg.conf ] ; then
    ADDRESS=$(grep NetworkAddress: $RASPGDIR/etc/raspg.conf | awk '{print $2}')
else
    echo 'RG: Not found: ' $RASPGDIR/etc/raspg.conf
fi

if [ chk$ADDRESS == "chk" ] ; then
    SETADDRESS=192.168.72.1
    SETMASK=255.255.255.0
else
    addrtmp=$(echo $ADDRESS | sed  -e 's/\// /')
    SETADDRESS=$(echo $addrtmp | awk '{print $1}')
    mask=$(echo $addrtmp | awk '{print $2}')
    SETMASK=$((echo "n=$mask" ; echo 't=32 - n' ; echo 'a=(2^n -1)*2^t' ; echo 'print b0=(a / 2^24) % 2^8,".",(a / 2^16) % 2^8,".",(a / 2^8) % 2^8,".",a % 2^8' ) | bc )
fi

CONF=/etc/udhcpd.conf

mv  $CONF  ${CONF}.0
echo '# Raspberry Gate Config' > $CONF
(echo -n '#' ; date ) >> $CONF
echo -n 'start   ' >> $CONF
echo $SETADDRESS | sed -e 's/\.1$/.33/' >> $CONF
echo -n 'end     ' >> $CONF
echo $SETADDRESS | sed -e 's/\.1$/.191/' >> $CONF
echo 'interface	eth1' >> $CONF
echo 'opt	dns	8.8.8.8 8.8.4.4' >> $CONF
echo  'opt subnet  ' $SETMASK >> $CONF
echo -n 'opt router  ' >> $CONF
echo $SETADDRESS | sed -e 's/\.1$/.1/' >> $CONF


## GET WAN side ip address 
dhclient eth0


ifconfig eth1 $SETADDRESS netmask $SETMASK

iptables --table nat --append POSTROUTING --out-interface eth0 --jump MASQUERADE
iptables --append FORWARD --in-interface eth1 --jump ACCEPT

/usr/sbin/udhcpd 


#!/bin/bash
MEDIA=/raspgmedia
CONF=/opt/raspg/etc/raspg.conf

if [ ! -d $MEDIA ] ; then
    mkdir $MEDIA
fi

if [ ! -b /dev/sda1 ] ; then
    exit 0
fi

mount /dev/sda1 $MEDIA

if [ -f $MEDIA/raspg.txt ] ; then
    diff /opt/raspg/etc/raspg.conf $MEDIA/raspg.txt >& /dev/null
    if [ $? -ne 0 ] ; then
	# 1: different
	# 2: no $CONF file
	cp $MEDIA/raspg.txt $CONF
    fi
fi

umount $MEDIA

exit 0




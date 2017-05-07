#!/bin/bash
PARENT=`readlink -f .`
echo " "
echo "***************************************************************"
echo "***************************************************************"
echo "             Unpacking system.img, Please Wait...              "
echo "***************************************************************"
echo "***************************************************************"
echo " "
if [ ! -e $PARENT/system ]; then
	mkdir $PARENT/system
fi
if [ -e $PARENT/system.img ]; then
	sudo mount -t ext4 -o loop $PARENT/system.img $PARENT/system
	sudo chmod 777 -R $PARENT/system
else
	./tools/simg2img $PARENT/system.img $PARENT/system.img
	sudo mount -t ext4 -o loop $PARENT/system.img $PARENT/system
	sudo chmod 777 -R $PARENT/system
fi

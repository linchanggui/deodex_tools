#!/bin/bash
PARENT=`readlink -f .`
echo " "
echo "***************************************************************"
echo "***************************************************************"
echo "             Repacking system.img, Please Wait...              "
echo "***************************************************************"
echo "***************************************************************"
echo " "
./tools/make_ext4fs -s -l 1073741824 -a system $PARENT/system_new.img $PARENT/system/
sudo chmod 777 $PARENT/system_new.img

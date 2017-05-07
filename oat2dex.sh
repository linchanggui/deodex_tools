#!/bin/bash

PARENT=`readlink -f .`
APP=$PARENT/system/app/*
PRIV=$PARENT/system/priv-app/*
FW=$PARENT/system/framework
SYSTEM=$PARENT/system
echo "**************************************************************"
echo "**************************************************************"
echo "                 !!!!!!Now Deodexing!!!!!!                    "
echo "**************************************************************"

if [ -e $SYSTEM/framework ]; then
	if [ ! -e $FW/*/*.dex ]; then
		if [ -e $SYSTEM/framework/arm64/boot.oat ]; then

			echo " "
			echo "***************************************************************"
			echo "***************************************************************"
			echo "          Found 'boot.oat', Setting Up BootClassPath           "
			echo "***************************************************************"
			echo "***************************************************************"
			echo " "
			sleep 2

			java -jar $PARENT/tools/oat2dex.jar boot $SYSTEM/framework/arm64/boot.oat
			mv  $FW/arm64/odex $PARENT/odex
			chmod 755 -R $SYSTEM
		else
			echo "The 'boot.oat' Doesn't Even Exist, You Need To Include The Whole Framework Folder!"
			echo "If You Already De-odexed, Then What Are You Doing???"
			sleep 2
			exit 0	
		fi

		echo " "
		echo "***************************************************************"
		echo "***************************************************************"
		echo "                  De-Opt/Deodexing /framework                  "
		echo "***************************************************************"
		echo "***************************************************************"
		echo " "
		sleep 2

		find $FW/arm64/dex -type f -exec rm -f ../{} \;
		find $FW/arm64/dex -name '*.dex' -type f -execdir mv {} .. \;
		find $FW -name '*.odex' -type f -exec java -jar $PARENT/tools/oat2dex.jar {} odex \;

		if [ -e $FW/android.policy.jar ]; then
			mkdir -p $FW/android.policy
			mv $FW/android.policy.jar $FW/android.policy/android.policy.jar
		fi

		for file in $FW/*.jar; do
			dir=${file%%.*}
			mkdir -p "$dir"
			mv "$file" "$dir"
		done

		if [ -e $FW/android ]; then
			mv $FW/android $FW/android.test.runner
		fi

		find $FW -name '*.dex' -type f -execdir mv {} .. \;

		if [ -e $FW/android.test.runner.dex ]; then
			mv $FW/android.test.runner.dex $FW/android.test.runner/android.test.runner.dex
		fi
		if [ -e $FW/android.policy.dex ]; then
			mv $FW/android.policy.dex $FW/android.policy/android.policy.dex
		fi
		if [ -e $FW/framework-classes2.dex ]; then
			mv $FW/framework-classes2.dex $FW/framework/framework-classes2.dex
		fi

		for file in $FW/*.dex; do
			dir=${file%%.*}
			mv "$file" "$dir"
		done

		find $FW -name '*2.dex' -type f -execdir mv {} classes2.tmp \;
		find $FW -name '*3.dex' -type f -execdir mv {} classes3.tmp \;
		find $FW -name '*.dex' -type f -execdir mv {} classes.dex \;
		find $FW -name '*2.tmp' -type f -execdir mv {} classes2.dex \;
		find $FW -name '*3.tmp' -type f -execdir mv {} classes3.dex \;
	else
		echo "This Has Already Been Deodexed!"
	fi	
else
	echo "The /framework Folder Doesn't Even Exist, Try Adding It First!"
	sleep 2
	exit 0
fi

#################################################

if [ -e $SYSTEM/app ]; then
	if [ ! -e $APP/*.dex ]; then
		echo " "
		echo "***************************************************************"
		echo "***************************************************************"
		echo "                     De-Opt/Deodexing /app                     "
		echo "***************************************************************"
		echo "***************************************************************"
		echo " "
		sleep 2

		find $APP -name '*.odex' -type f -exec java -jar $PARENT/tools/oat2dex.jar {} odex \;
		find $APP -name '*2.dex' -type f -execdir mv {} classes2.tmp \;
		find $APP -name '*3.dex' -type f -execdir mv {} classes3.tmp \;
		find $APP \( -name "*.dex" -or -name "*.tmp" \) -type f -execdir mv {} ../.. \;
		find $APP -name '*.dex' -type f -execdir mv {} classes.dex \;
		find $APP -name '*2.tmp' -type f -execdir mv {} classes2.dex \;
		find $APP -name '*3.tmp' -type f -execdir mv {} classes3.dex \;
	else
		echo "This Has Already Been Deodexed!"
	fi
else
	echo "The /app Folder Doesn't Even Exist, Try Adding It First!"
	sleep 2
	exit 0
fi

#################################################

if [ -e $SYSTEM/priv-app ]; then
	if [ ! -e $PRIV/*.dex ]; then
		echo " "
		echo "***************************************************************"
		echo "***************************************************************"
		echo "                  De-Opt/Deodexing /priv-app                   "
		echo "***************************************************************"
		echo "***************************************************************"
		echo " "
		sleep 2

		find $PRIV -name '*.odex' -type f -exec java -jar $PARENT/tools/oat2dex.jar {} odex \;
		find $PRIV -name '*2.dex' -type f -execdir mv {} classes2.tmp \;
		find $PRIV -name '*3.dex' -type f -execdir mv {} classes3.tmp \;
		find $PRIV \( -name "*.dex" -or -name "*.tmp" \) -type f -execdir mv {} ../.. \;
		find $PRIV -name '*.dex' -type f -execdir mv {} classes.dex \;
		find $PRIV -name '*2.tmp' -type f -execdir mv {} classes2.dex \;
		find $PRIV -name '*3.tmp' -type f -execdir mv {} classes3.dex \;
	else
		echo "This Has Already Been Deodexed!"
	fi
else
	echo "The /priv-app Folder Doesn't Even Exist, Try Adding It First!"
	sleep 2
	exit 0
fi

#################################################

chmod 777 -R $SYSTEM

echo " "
echo "***************************************************************"
echo "***************************************************************"
echo "      Now, Adding .dex And /lib To The Correct Apks/Jars       "
echo "***************************************************************"
echo "***************************************************************"
echo " "
sleep 2

find $APP -name '*.apk' -type f -execdir zip -q {} classes.dex classes2.dex classes3.dex -r lib \;
find $PRIV -name '*.apk' -type f -execdir zip -q {} classes.dex classes2.dex classes3.dex -r lib \;
find $FW -name '*.jar' -type f -execdir zip -q {} classes.dex classes2.dex classes3.dex \;
find $FW -name '*.jar' -type f -execdir mv {} .. \;

echo " "
echo "***************************************************************"
echo "***************************************************************"
echo "                  Cleaning Up Un-Needed Files                  "
echo "***************************************************************"
echo "***************************************************************"
echo " "
sleep 2

find $PARENT/* -name '*.dex' -exec rm -rf {} \;
find $PARENT/* -name '*.odex' -exec rm -rf {} \;
rm -rf $FW/arm64
rm -rf $PARENT/odex
find $PARENT/* -type d -empty -exec rmdir {} \; 2> /dev/null

echo " "
echo "***************************************************************"
echo "***************************************************************"
echo "                          Finished!!!                          "
echo "***************************************************************"
echo "***************************************************************"
echo " "

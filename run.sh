#!/bin/bash

export MODULENAME=mt7610u
export CLONEDIR=~/src/$MODULENAME
export DRIVERKERNELPATH=/usr/src/$MODULENAME-1.0
export DRIVERNAME=$MODULENAME/1.0
export KSRC=/lib/modules/$(uname -r)/source
export TARGET_ARCH=amd64
export GITHUBPATH=https://github.com/cyangy/A6210-mt76x2u_Ubuntu.git

function errormsg () {
	echo -e "\e[31m$1\e[0m"
}

function printcode () {
	echo -e "\e[93m$1\e[0m"
}

function okmsg () {
	echo -e "\e[42m\e[30m$1\e[0m"
}

function msg () {
	echo -e "\e[44m$1\e[0m"
}

function fatal () {
	errormsg "!!! FATAL ERROR !!! $1"
	exit 1
}

function runcode () {
	msg "$1"
	printcode "$2"
	eval "$2" || fatal "$1 died with error code $?"
}

if [ $EUID -ne 0 ]; then 
	errormsg "Please run:"
	printcode "	sudo bash $0"
	exit
else
	okmsg "Ok, you are already root. Continueing"
fi

if ping -c 1 google.de &> /dev/null; then
	okmsg "Seems like you are connected to the internet. Going on..."
else
	fatal "Please connect a network cable! You need to be online for this installation"
fi

if lsusb | grep -qi $MODULENAME; then
	fatal "Please disconnect the network adapter from USB and restart this setup"
else
	okmsg "The network adapter is disconnected (leave it this way until the setup is finished)"
fi

if lsmod | egrep -q "^mt76"; then
	runcode "The kernel module $MODULENAME is already loaded. Removing it for now..." "rmmod mt76"
else
	okmsg "The kernel module mt76 is not already loaded. Going on with setup."
fi

runcode "Installing git" "apt-get install -y git"
runcode "Installing build-essentials" "apt-get install -y build-essential"
#runcode "Installing dkms" "apt-get -y install dkms"
runcode "Downloading kernel source" "apt-get install -y linux-headers-$(uname -r)"

runcode "Removing old $CLONEDIR if it exists" "rm -rf $CLONEDIR"
runcode "Creating $CLONEDIR" "mkdir -p $CLONEDIR"
runcode "Cloning git driver repository to $CLONEDIR" "git clone $GITHUBPATH $CLONEDIR"

runcode "Changing dir to $CLONEDIR" "cd $CLONEDIR"

runcode "Cleaning directory $CLONEDIR" "make"
runcode "Making driver" "make -j $(expr $(nproc) + 1)"
runcode "Installing driver" "make install"
runcode "Inserting driver into Kernel" "modprobe mac80211"
runcode "Modprobing kernel module for $DRIVERNAME" "modprobe mt76"

if cat /etc/modules | egrep -q "^mt76"; then
	okmsg "Already autoloading mt76"
else
	runcode "Adding mt76 to /etc/modules" "echo 'mt76' >> /etc/modules"
fi

runcode "Auto-removing old packages" "apt-get -y autoremove"


okmsg "Ok. It seems like everything worked. Please restart your computer and plugin the Wifi-adapter.."

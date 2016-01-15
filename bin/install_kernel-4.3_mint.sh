#!/bin/bash

mkdir /tmp/inst-kernel
cd /tmp/inst-kernel; 

wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.3.3-wily/linux-headers-4.3.3-040303-generic_4.3.3-040303.201512150130_i386.deb http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.3.3-wily/linux-headers-4.3.3-040303_4.3.3-040303.201512150130_all.deb http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.3.3-wily/linux-image-4.3.3-040303-generic_4.3.3-040303.201512150130_i386.deb;
sudo dpkg -i *.deb
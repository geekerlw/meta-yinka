#!/bin/bash -e

# set default port and device
if [ ! $TTY ]; then
	if [ -c "/dev/ttyUSB0" ]; then
		TTY="/dev/ttyUSB0"
	else
		echo "no support tty device"
		exit 1
	fi
fi
if [ ! $DEVICE ]; then
	if [ -b "/dev/sda" ]; then
		DEVICE="/dev/sdc"
	else
		echo "no support block device"
		exit 1
	fi
fi

# remove exist sources
if [ -d "u-boot" ]; then
	rm -rf u-boot
fi
if [ -d "kernel" ]; then
	rm -rf kernel
fi
if [ -d "ubuntu" ]; then
	rm -rf ubuntu
fi

# prepare sources
if [ -f update.tar.gz ]; then
	tar -xvf update.tar.gz
else
	exit 1
fi

# prepare binary run environment
apt install -y libc6:i386 libc6-i386
chmod +x ./tools/rkdeveloptool

# set serial
stty -F $TTY ispeed 115200 ospeed  115200 cs8

# flash uboot
# make sure your board is in maskrom mode
./tools/rkdeveloptool db u-boot/prebuild/rk3288_ubootloader_v1.01.06.bin
./tools/rkdeveloptool wl 0x40 u-boot/u-boot-rk3288.img
./tools/rkdeveloptool rd

# wait seconds to restart board
sleep 3

# interrupt when start
echo -e "\x03" > $TTY

# write partition info to emmc
echo -e "gpt write mmc 0 \$partitions" > $TTY

# save gpt partition info on emmc
echo -e "env save" > $TTY

# change to ums mode
echo -e "ums 0 mmc 0" > $TTY

# wait seconds to restart board
sleep 3

# formatted partition
mkfs.fat $DEVICE\1
mkfs.ext4 $DEVICE\2 
mkfs.ext4 $DEVICE\3

# copy linux kernel to kernel partition
mount $DEVICE\1 /mnt
cp -av kernel/* /mnt
umount /mnt

# copy ubuntu file system to fs partition
mount $DEVICE\2 /mnt
cp -av ubuntu/* /mnt
umount /mnt

# copy ubuntu file system to backup partition
mount $DEVICE\3 /mnt
cp -av ubuntu/* /mnt
umount /mnt

# interrupt when ums stop
echo -e "\x03" > $TTY

# restart board
echo -e "boot" > $TTY

# remove no needed resource
rm -rf kernel u-boot ubuntu

# flash success
echo -e "\033[1m\033[34m \n-------- Flash successful --------\n---- Auther: geekerlw@gmail.com ----\n \033[0m"

exit 0

# meta-yinka
---
## Introduction
      This repo is design to support one key flash yinka board
## Notice
    I don't know the environment of your pc, before you use the script, make sure that you have the serial   
    port and the device is in the maskrom mode. For example, my pc's block device is /dev/sda and /dev/sdb,   
    so when I plug the board's otg in, the device port is become into /dev/sdc, and my usb serial port is   
    /dev/ttyUSB0, so I set default environments to /dev/ttyUSB0 and /dev/sdc 
## usage
    make sure you are use in root
    when use the default sets(set the Notice):
    ./yinka-flash.sh
    
    when use your own sets:
    TTY=<type_your_serial_port> DEVICE=<type_your_device> ./yinka-flash.sh

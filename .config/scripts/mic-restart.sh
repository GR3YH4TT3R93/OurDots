#!/usr/bin/bash

lsusb | grep -i "mic" | awk -F' ' '{print $6}' | sed 's/:/ /' | awk -F' ' '{print "sudo usbreset " $1 ":" $2}' | bash

#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "Too many args" 1>&2
  exit 1
fi

jail=$1
if ! [ -d /jail/$jail ]; then
  echo "Not a valid jail" 1>&2
  exit 2
fi

#service jail stop $jail
sed -i '' "/$jail/d" /etc/fstab
umount /jail/$jail
rmdir /jail/$jail
rm /jail/fstab/$jail


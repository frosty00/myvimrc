#!/usr/bin/env bash

if [ $# -gt 2 ] || [ $# -eq 0 ]; then
  echo "Too many args" 1>&2
  exit 1
fi

if ! gpart show -l da0 | grep -q clone; then
  echo "clone not ready" 1>&2
  new_device=$(gpart add -l clone -s 10g -t freebsd-ufs -a 4k da0 | cut -d' ' -f1)
  lockf /home/clone.lock dd if=/dev/gpt/base of=/dev/$new_device bs=4m &
  exit 3
fi


partition=$(gpart show -l da0 | grep clone | head -n 1 | awk '{ print $3 }')
pdevice=/dev/da0p$partition

if [ $# -eq 2 ]; then
  if [ "$1" = '-f' ]; then
    echo "cloning base into $pdevice" 1>&2
    lockf /home/clone.lock dd if=/dev/gpt/base of=$pdevice bs=4m
    shift
  else
    echo "Expecting the first argument to be the -f flag" 1>&2
    exit 2
  fi
fi

jail=$1
gpart modify -i $partition -l $jail da0

mkdir /jail/$jail

tmp=$(mktemp)
cp /etc/fstab $tmp
echo "/dev/gpt/$jail  /jail/$jail  ufs  rw  2  2" >> $tmp
column -t < $tmp > /etc/fstab

column -t<<EOF > /jail/fstab/$jail
#Device         Mountpoint                 FStype  Options  Dump  Pass#
/usr/share/bin  /jail/$jail/usr/share/bin  nullfs  rw       2     2
EOF

cat<<EOF >> /etc/jail.conf

$jail {

}
EOF

mount $pdevice /jail/$jail

# buffer the creation of new jails at end
newpart=$(gpart add -s 10g -l clone -t freebsd-ufs -a 4k da0 | cut -d ' ' -f1)
echo "cloning base into $newpart"
lockf /home/clone.lock dd if=/dev/gpt/base of=/dev/$newpart bs=4m &

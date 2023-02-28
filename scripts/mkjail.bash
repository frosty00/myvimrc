#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "Too many args" 1>&2
  exit 1
fi

if ! gpart show -l da0 | grep clone; then
  echo "clone not ready" 1>&2
  exit 2
fi

jail=$1

partition=$(gpart show -l da0 | grep clone | head -n 1 | awk '{ print $3 }')
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

mount /dev/da0p$partition /jail/$jail

# buffer the creation of new jails at end
newpart=$(gpart add -s 10g -l clone -t freebsd-ufs -a 4k da0 | cut -d ' ' -f1)
echo "cloning base into $newpart"
lockf /home/clone.lock dd if=/dev/gpt/base of=/dev/$newpart bs=4m &

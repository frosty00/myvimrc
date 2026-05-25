#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "Too many args" 1>&2
  exit 1
fi

user=$1
home=/home/$user
pw user add -n $user -d $home -m -s $SHELL
cp ~/.bashrc ~/.profile $home
su $user

echo "new home directory $home created for $user"

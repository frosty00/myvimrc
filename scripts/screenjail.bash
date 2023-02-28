#!/usr/bin/env bash

# start a screen with each window attached to the different jails
if screen -S jails -Q "select" > /dev/null; then
  echo "a screen session called jails already exists" 1>&2
  exit 1
fi

# only way to get color when starting a detached session
screen -dmS jails -t htop bash -c 'export TERM=screen-256color; exec bash -c htop'
for jail in $(jls -N | awk '{ print $1 }' | tail -n +2); do
  screen -S jails -X screen -t $jail
  screen -S jails -p $jail -X exec jexec -lU root $jail $SHELL
done

screen -r jails

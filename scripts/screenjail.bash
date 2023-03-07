#!/usr/bin/env bash

set -x
# start a screen with each window attached to the different jails
if screen -S jails -Q "select" > /dev/null; then
  echo "quitting a screen session called jails" 1>&2
  screen -S jails -X quit
  sleep 1
  screen -ls
fi

# only way to get color when starting a detached session
screen -dmS jails -t htop bash -c 'export TERM=screen-256color; exec bash -c htop'
for jail in $(jls -N | awk '{ print $1 }' | tail -n +2); do
  screen -S jails -X screen -t $jail
  screen -S jails -p $jail -X exec jexec -lU root $jail $SHELL
  sleep 0.1
done

screen -r jails

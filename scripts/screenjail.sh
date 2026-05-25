#!/usr/bin/env bash

set -e

# start a screen with each window attached to the different jails
if screen -S jails -Q "select" > /dev/null; then
  echo "quitting a screen session called jails" 1>&2
  screen -S jails -X quit
  sleep 1.5
  screen -ls || true
  sleep 1
fi

# only way to get color when starting a detached session
screen -dmS jails -t htop bash -c 'export TERM=screen-256color; exec bash -c htop'
for jail in $(jls -N | awk '{ print $1 }' | tail -n +2); do
  screen -S jails -X screen -t $jail
  user=root
  run=$SHELL
  if [ "$jail" = rebates ]; then
    user=rebates
  else
    user=root
  fi
  screen -S jails -p $jail -X exec jexec -lU $user $jail $SHELL
  sleep 0.2
done

$(sleep 3 && ./tty_size.bash 2> /dev/null) &

screen -r jails


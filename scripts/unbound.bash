#!/usr/bin/env bash

set -x

function _quit {
  echo "$1" 2>&1
  exit 1
}

function _unbound {
  jexec -lU root unbound "$@"
}


if [ "$(hostname)" != "s49910.dedi.leaseweb.net" ]; then
  _quit "cannot start from a jail"
fi

if ! jls -N | grep -q unbound; then
  _quit "unbound jail not found"
fi

jails=$(jls -N | sed -e '1d' -e '/unbound/d' | awk '{ print $1 }' | xargs)

if ! _unbound ifconfig localswitch > /dev/null 2>&1; then
  _unbound ifconfig bridge create name localswitch up || _quit "failed to create bridge localswitch"
fi

i=2
for jail in $jails host; do
  new_epair="local_${jail}_a"
  new_jail_epair="local_${jail}_b"
  if ! _unbound ifconfig $new_epair > /dev/null 2>&1; then
    name=$(_unbound ifconfig epair create) || _quit "failed to create epair for $new_epair"
    new_name=$(_unbound ifconfig $name name $new_epair up) || _quit "failed to rename $new_epair"
    _unbound ifconfig "${name%a}b" name $new_jail_epair || "failed to rename second part of $name"
    _unbound ifconfig localswitch addm $new_name private $new_name || _quit "failed to add $new_name to localswitch bridge"

    ifconfig $new_jail_epair -vnet unbound || _quit "failed to attach the epair to the host"
    local_ip="192.168.0.$i"
    ((i++))
    if [ $jail = host ]; then
      ifconfig $new_jail_epair inet $local_ip up || _quit "failed to bring up the epair on the host"
    else
      # attach the jail epair to the jail's vnet
      ifconfig $new_jail_epair vnet $jail || _quit "failed to attach the epair to the jail $jail"
      jexec -lU root $jail ifconfig $new_jail_epair inet $local_ip up || _quit "failed to bring the epair on the side of the jail $jail up"
    fi
  fi
done

if ! _unbound ifconfig endpoint_a > /dev/null 2>&1; then
  name=$(_unbound ifconfig epair create) || _quit "failed to create an epair for the endpoint"
  _unbound ifconfig $name name endpoint_a up || _quit "failed to rename epair for endpoint"
  _unbound ifconfig "${name%a}b" name endpoint_b up || _quit "failed to rename epair for endpoint"
  _unbound ifconfig localswitch addm endpoint_a || _quit "failed to add the endpoint to the bridge"
fi

_unbound ifconfig endpoint_b inet 192.168.0.1/16 || _quit "failed to assign the endpoint an ip address"
_unbound service local_unbound onestart

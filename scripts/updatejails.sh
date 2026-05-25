#!/usr/bin/env bash

TARGET="13.5"

if ! screen -ls | grep -q update-jails; then
  screen -dmS update-jails
fi

host=$(freebsd-version)
for jail in $(jls -N | awk '{ print $1 }' | tail -n +2); do
  version=$(freebsd-version -j "$jail")
  if [ "$version" != "$host" ]; then
    echo -e "\nUpdating $jail from $version to $TARGET\n"
    read -p "Do you want to continue? (y/n): " choice
    if [ "$choice" != 'y' ]; then
      break;
    fi
    path="/jail/$jail"
    wd="/usr/db/freebsd-update/$jail"
    mkdir -p "$wd"
    screen -S update-jails -X screen -t "$jail"
    command=$(cat <<EOF
export PAGER=cat; freebsd-update -d "$wd" -b "$path" -j "$jail" upgrade -r "$TARGET" && \
freebsd-update -d "$wd" -b "$path" -j "$jail" install && \
freebsd-update -d "$wd" -b "$path" -j "$jail" install
EOF
)
    screen -S update-jails -p "$jail" -X stuff "$command"
  fi
done

# screen -S update-jails -X quit

#!/bin/sh

find /root/myvimrc/home -maxdepth 1 -type f -print0 | xargs -0 -I {} ln -s -f {} /root/

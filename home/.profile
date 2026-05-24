# $FreeBSD$
#
export PATH=/usr/share/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:~/bin
export TERM=${TERM:-xterm}
export PAGER=less
export EDITOR=vim


# Query terminal size; useful for serial lines.
#if [ -x /usr/bin/resizewin ] ; then /usr/bin/resizewin -z ; fi


# add color to the terminal
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export PS1="\[$(tput AF 2)\]\w\[$(tput AF 5)\]\$ \[$(tput me)\]"

if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

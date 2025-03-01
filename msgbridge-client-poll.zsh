#!/bin/zsh

typeset host="$1"
shift

if [[ -z $host ]]
then
  print 'msgbridge-client-poll.zsh <ssh_host> [<polling_interval_sec>]' >&2
  exit 1
fi

typeset -i interval="${1:-$(( 5 * 60 ))}"
typeset host_self=$(hostname)

(
  while sleep ${interval}
  do
    ssh -i ~/tmp/test_ecdsa ${host} msgbridge-server-get.zsh ${host_self} | msgbridge-client.rb
  done
) &

cpid=${!}

yad --notification --image=gtk-dialog-info

kill $cpid
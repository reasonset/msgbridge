#!/bin/zsh

setopt NULL_GLOB

host="$1"
shift

typeset data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/msgbridge/msgs/${host}"

if [[ ! -e $data_dir ]]
then
  print "Invalid host." >&2
  exit 1
fi

for i in "${data_dir}"/*
do
  cat $i && rm $i
done

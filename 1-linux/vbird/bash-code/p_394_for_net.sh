#!/bin/bash

network="192.168.0"
for sitenu in $(seq 1 30)
do
  ping -c 1 -w ${network}.${sitenu} &>/dev/null && result=0 || result=1
  if [ "$result" == 0 ]; then
    echo "Server ${network}.${sitenu} is UP."
  else
    echo "Server ${network}.${sitenu} is DOWN."
  fi
done

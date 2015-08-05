#!/bin/sh

if test -z $MECH; then
  MECH=m0
fi

echo ssh -i resources/ssh/try.key yoda@$(azure vm show $MECH -g mesos-sandbox \
  | grep "Public IP address" \
  | ./extract_public_ip_for_mech.awk \
  | sed -e 's_:__g')

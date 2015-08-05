#!/bin/sh

if test -z $MECH; then
  MECH=m0
fi

if test -z $GROUP; then
  GROUP=mesos-sandbox
fi

if test -z $USER; then
  USER=yoda
fi

if test -z $KEY_FILE; then
  KEY_FILE=resources/ssh/try.key
fi

if test "$1" == "up"; then
  ssh -i $KEY_FILE $USER@$(azure vm show $MECH -g $GROUP \
    | grep "Public IP address" \
    | ./extract_public_ip_for_mech.awk \
    | sed -e 's_:__g')
elif test "$1" == "down"; then
  echo "N/A"
else
  echo "Usage: GROUP=? MECH=? USER=? $0 up"
fi

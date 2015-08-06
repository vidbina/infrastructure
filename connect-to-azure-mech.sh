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
  source helpers/ip_for_azure_mech.sh

  if test -n "$REMOTE_MECH"; then
    MECH=$TUNNEL_MECH
    TUNNEL_HOST=$(public_ip_for_azure_mech)

    MECH=$REMOTE_MECH
    REMOTE_HOST=$(private_ip_for_azure_mech)
  
    ssh -i $KEY_FILE $USER@$TUNNEL_HOST -f -nNTX -L $TUNNEL_PORT:$REMOTE_HOST:22
    ssh -i $KEY_FILE $USER@localhost -p $TUNNEL_PORT
    kill -3 $(ps aux | grep $TUNNEL_PORT:$REMOTE_HOST:22 | grep $USER@$TUNNEL_HOST | grep -Fv 'grep' | awk '{print $2}')
  else
    REMOTE_HOST=$(public_ip_for_azure_mech)
    ssh -i $KEY_FILE $USER@$REMOTE_HOST
  fi
elif test "$1" == "down"; then
  echo "N/A"
else
  echo "Usage: GROUP=? [MECH=? | [TUNNEL_MECH=? REMOTE_MECH=? TUNNEL_PORT=?]] USER=? $0 up"
fi

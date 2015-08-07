#!/bin/sh

if test -z $REMOTE_PORT; then
  REMOTE_PORT=5050
fi

if test -z $REMOTE_HOST; then
  REMOTE_HOST=127.0.0.1
fi

if test -z $LOCAL_PORT; then
  LOCAL_PORT=$REMOTE_PORT
fi

if test -z $TUNNEL_HOST; then
  TUNNEL_HOST=$REMOTE_HOST
fi

if test -z $LOCAL_HOST; then
  LOCAL_HOST_STR=
else
  LOCAL_HOST_STR=$LOCAL_HOST
fi

if test -z $KEY; then
  KEY="resources/ssh/try.key"
fi

function derrive_hosts() {
  source helpers/ip_for_azure_mech.sh
  
  if test -n $TUNNEL_MECH; then
    MECH=$TUNNEL_MECH
    TUNNEL_HOST=$(ip_for_azure_mech)
  fi

  if test -n $REMOTE_MECH; then
    MECH=$REMOTE_MECH
    REMOTE_HOST=$(private_ip_for_azure_mech)
  fi
}

if test "$1" == "up"; then
  if test -z $GROUP; then
    echo "Specify GROUP"
    exit;
  fi

  derrive_hosts
  ssh -i $KEY -f -nNT -L $LOCAL_HOST_STR$LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT $USER@$TUNNEL_HOST
elif test "$1" == "down"; then
  derrive_hosts
  kill -3 $(ps aux | grep -F $LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT | grep -F $USER@$TUNNEL_HOST | grep -Fv 'grep' | awk '{print $2}')
else
  echo "Usage: [LOCAL_PORT=?] [USER=?] [REMOTE_HOST=? | REMOTE_MECH=?] [REMOTE_PORT=?] [TUNNEL_HOST=? | TUNNEL_MECH=?] [KEY=?] $0 (up|down)"
fi

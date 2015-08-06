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

if test -z $CERT_FILE; then
  CERT_FILE="resources/ssh/try.key"
fi

if test "$1" == "up"; then
  if test -z $MECH; then
    echo "Specify MECH"
    exit;
  fi
  
  if test -z $GROUP; then
    echo "Specify GROUP"
    exit;
  fi

  source helpers/ip_for_azure_mech.sh
  
  AZURE_MECH_IP=$(ip_for_azure_mech)
  REMOTE_HOST=$AZURE_MECH_IP
  ssh -i $CERT_FILE -f -nNT -L $LOCAL_HOST_STR$LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT $USER@$AZURE_MECH_IP
elif test "$1" == "down"; then
  #kill -3 $(ps aux | grep -E 'ssh.*google.' | grep -F $LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT | grep -F $USER@$TUNNEL_HOST | grep -Fv 'grep' | awk '{print $2}')
  kill -3 $(ps aux | grep -F $LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT | grep -F $USER@$(ip_for_azure_mech) | grep -Fv 'grep' | awk '{print $2}')
else
  echo "Usage: [LOCAL_PORT=?] [USER=?] [REMOTE_HOST=?] [REMOTE_PORT=?] [TUNNEL_HOST=?] [CERT_FILE=?] $0 (up|down)"
fi

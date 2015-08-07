#!/bin/sh
if test -z $REMOTE_PORT; then
  REMOTE_PORT=5050
fi

if test -z $GROUP; then
  GROUP=mesos-sandbox
fi

if test -z $REMOTE_HOST; then
  REMOTE_HOST=127.0.0.1
fi

if test -z $LOCAL_PORT; then
  LOCAL_PORT=5050
fi

if test -z $TUNNEL_HOST; then
  TUNNEL_HOST=$REMOTE_HOST
fi

if test -z $LOCAL_HOST; then
  LOCAL_HOST_STR=
else
  LOCAL_HOST_STR=$LOCAL_HOST
fi

if test -z $IMAGE; then
  #IMAGE="2b171e93f07c4903bcad35bda10acf22__CoreOS-Stable-647.2.0"
  IMAGE="CoreOS:CoreOS:Stable:723.3.0"
fi

if test -z $REGION; then
  REGION="West Europe"
fi

if test -z $SIZE; then
  SIZE="Standard_A0"
fi

if test -z $USER; then
  USER="yoda"
fi

if test -z $CERT_FILE; then
  CERT_FILE="resources/ssh/try.pem"
fi

if test -z $CLOUD_CONF; then
  CLOUD_CONF="resources/cloud-config/mesos-standard.yaml"
fi

if test -z $VNET; then
  VNET="sandbox-vnet"
fi

if test -z $VNET_SUBNET; then
  SUBNET="initial-sandbox-subnet"
fi

if test "$1" == "up"; then
  #azure config mode arm
  #echo azure vm create -g $GROUP -n $NAME -l \"$REGION\" -y Linux -q $IMAGE -M $CERT_FILE -u $USER -z $SIZE
  set -x
  azure vm create --resource-group $GROUP \
    --name $NAME \
    --location "$REGION" \
    --os-type Linux \
    --image-urn $IMAGE \
    --ssh-publickey-pem-file $CERT_FILE \
    --admin-username $USER \
    --vm-size $SIZE \
    --nic-name $NAME-nic-a \
    --vnet-name "$VNET" \
    --vnet-subnet-name "$SUBNET" \
    $EXTRA
  set +x
elif test "$1" == "down"; then
  azure vm delete -n $NAME -g $GROUP
else
  echo "Usage: [LOCAL_PORT=?] [USER=?] [REMOTE_HOST=?] [REMOTE_PORT=?] [TUNNEL_HOST=?] [CERT_FILE=?] $0 (up|down)"
fi

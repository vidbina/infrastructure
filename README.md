# Mesos Infrastructure

## Create VM

```bash
USER=yoda \
NAME=tie-figher \
SIZE=Standard_A0 \
GROUP=jedi-sandbox \
CERT_FILE=resources/ssh/yoda.pem \
EXTRA="--public-ip-addr sandbox-addr -C resource/cloud-config/mesos-standard.yml" \
./create-azure-mech.sh up
```

## Connect to VM

```bash
USER=yoda \
MECH=tie-fighter \
GROUP=jedi-sandbox \
KEY_FILE=resources/ssh/yoda.key \
./connect-to-azure-mech up
```

# Cheatsheet

## Publc Addresses

```bash
azure network public-ip create mesos-sandbox gateway-addr westeurope
```

## Create NIC

```bash
azure network nic create gateway-nic
--resource-group mesos-sandbox \
--location westeurope \
--subnet-name initial-sandbox-subnet \
--subnet-vnet-name sandbox-vnet
--public-ip-name gateway-addr
```

## Create VM

```bash
USER=yoda NAME=m0 GROUP=mesos-sandbox SIZE=Standard_A0 \
EXTRA="--nic-name=gateway-nic --custom-data=resources/cloud-config/mesos-standard.yaml" \
./create-mesos.mech.sh up
```

## Tunnel to remote machine

Ensure `$GATEWAY_ADDR` represents the public IP address of the `gateway-addr `.

```bash
ssh -i resources/ssh/try.key -f -nNT -L 8080:$GATEWAY_ADDR:8080 yoda@$GATEWAY_ADDR
ssh -i resources/ssh/try.key -f -nNT -L 5050:$GATEWAY_ADDR:5050 yoda@$GATEWAY_ADDR
```

## Docker Sockets
The slave machine will need to be able to spawn docker containers on the host.
In order to make this possible one can utilize Docker sockets.

Find the docker slave PID

```bash
sudo docker inspect --format {{.State.Pid}} $CONTAINER_ID
```

Enter the container namespace:

```bash
sudo nsenter --target $PID --mount --uts --ipc --net --pid
```

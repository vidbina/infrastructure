# Mesos Infrastructure

All the helpers in this repository expect the Azure X-plat CLI to be configured
to run in the ARM mode. Ensure that the proper mode is selected/activated by
running:

```bash
azure config mode arm
```

<img src="http://i.giphy.com/KWV7mrud6Dq4o.gif" width="500" height="213" alt="C3PO" />

## Create VM

Create a VM and assign to it a public IP address (making it accessible from the
internet):

```bash
USER=yoda \
NAME=tie-figher \
SIZE=Standard_A0 \
GROUP=jedi-sandbox \
CERT_FILE=resources/ssh/yoda.pem \
EXTRA="--public-ip-addr sandbox-addr -C resource/cloud-config/mesos-standard.yml" \
./create-azure-mech.sh up
```

Create a VM and assign to it a NIC that may already be configured to use a 
given Public IP address. Note that assigning a NIC attached to a public IP 
address may change the address.

```bash
USER=yoda \
NAME=tie-figher \
SIZE=Standard_A0 \
GROUP=jedi-sandbox \
CERT_FILE=resources/ssh/yoda.pem \
EXTRA="--nic-name=gateway-nic --custom-data=resources/cloud-config/mesos-standard.yaml" \
./create-mesos-mech.sh up
```

**NOTE**: Apparently having a public address in this context means that you 
have the privilege of assigning one, but once you reassign the NIC (attach it 
to a different VM) the address may change. Still need to figure out this 
observation is correct.

```bash
azure network public-ip list -g jedi-sandbox
```

## Connect to VM

In order to setup a connection to a publicly visible VM (visible from the 
internet through a public IP address) one may run the following command, 
specifying the machine's name through the `MECH` variable.

```bash
USER=yoda \
MECH=tie-fighter \
GROUP=jedi-sandbox \
KEY_FILE=resources/ssh/yoda.key \
./connect-to-azure-mech up
```

In some cases, the machine of interest will not be front-facing (not connected
to the internet through a public IP address) which will require one to connect
through a gateway. In the next example the `TUNNEL_MECH` variable contains the 
name of the front-facing VM that is being used to _hop_ to the machine of 
interest, being the `REMOTE_MECH` VM. Note that the `TUNNEL_PORT` is the port 
that we locally forward to the remote machine's SSH port., subsequently 
allowing one to establish the connection to the remote machine through that 
very port. The establishing of the connection looking something like 
`ssh -i $USER@REMOTE_HOST -p $REMOTE_PORT` will be executed after setting up 
the tunnel, allowing you to just sit back and have the script cater to your 
needs. After disconnecting from the ssh connection, the tunnel is subsequently
destroyed.

```bash
USER=yoda \
TUNNEL_PORT=49152 \
TUNNEL_MECH=starship \
REMOTE_MECH=starfighter0 \
./connect-to-azure-mech.sh up
```

**NOTE**: The `TUNNEL_MECH` VM must have a public IP address in order for this
to work.

<img src="http://i.giphy.com/VUw1mb0qZY9vG.gif" width="709" height="344" alt="tunnel"/>

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

Use the helper to make things easier :wink:

```bash
USER=yoda \
MECH=tie-fighter \
GROUP=jedi-sandbox \
REMOTE_PORT=8080 \
KEY=/resources/ssh/yoda.key \
./tunnel-to-azure-mech.sh up
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

# Todo

 - [ ] Figure out if public IP addr are changed on NIC reassignment
 - [ ] Figure out how to use Azure LB in combination with Mesos services

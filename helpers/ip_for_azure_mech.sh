#!/bin/sh

# Retrieve the public IP address for a given machine
ip_for_azure_mech()
{
  azure vm show $MECH -g $GROUP \
    | grep "Public IP address" \
    | awk '{print $5}' \
    | sed -e 's_:__g'
}

public_ip_for_azure_mech() { 
  ip_for_azure_mech
}

# Retrieve the private IP address for a given machine
private_ip_for_azure_mech()
{
  azure vm show $MECH -g $GROUP \
    | grep "Private IP address" \
    | awk '{print $5}' \
    | sed -e 's_:__g'
}

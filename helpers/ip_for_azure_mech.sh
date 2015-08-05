#!/bin/sh

ip_for_azure_mech()
{
  azure vm show $MECH -g $GROUP \
    | grep "Public IP address" \
    | awk '{print $5}' \
    | sed -e 's_:__g'
}

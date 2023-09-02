#!/bin/bash -e

git clone https://github.com/pia-foss/manual-connections.git

sh -c ' VPN_PROTOCOL=wireguard \
  DISABLE_IPV6=yes \
  DIP_TOKEN=no \
  AUTOCONNECT=true \
  PIA_CONNECT=true \
  PIA_PF=false \
  PIA_DNS=true \
  PIA_USER=${PIA_USER} \
  PIA_PASS=${PIA_PASS} \
    ./manual-connections/run_setup.sh'

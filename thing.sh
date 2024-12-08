#!/usr/bin/bash

#Modified unofficial Bash strict mode
set -eo pipefail
IFS=$'\n\t'

#Use global profile
. /usr/share/defaults/etc/profile

#Install required dependencies
echo '——Install required dependencies——'


#Generate certificates
echo '——Generate certificates——'
letsencrypt certonly --standalone -d example.com -d www.example.com

certbot certonly -m compact-orb@compact-orb.ovh --eab-kid $EAB_KID --eab-hmac-key $EAB_HMAC_KEY --server https://acme.zerossl.com/v2/DV90 --csr compact-orb.ovh.csr --manual

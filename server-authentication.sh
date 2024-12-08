#!/usr/bin/bash

#Modified unofficial Bash strict mode
set -eo pipefail
IFS=$'\n\t'

#Save repository directory
REPOSITORY_DIR=$(pwd)

#Generate in /tmp
echo '——Build in /tmp——'
BUILD_DIR=/tmp
cd $BUILD_DIR

#Install required dependencies
echo '——Install required dependencies——'
sudo apt update
sudo apt --yes install python3-venv
python -m venv venv
source venv/bin/activate
pip install certbot
sudo ln --symbolic /tmp/venv/bin/certbot /usr/local/bin/certbot

#Generate certificates
echo '——Generate certificates——'
function generate-certificate {
	sudo certbot certonly --agree-tos -m compact-orb@compact-orb.ovh --eab-kid $EAB_KID --eab-hmac-key $EAB_HMAC_KEY --preferred-challenges dns-01 --server https://acme.zerossl.com/v2/DV90 --csr "$1.csr" --no-eff-email --manual
	awk '/-----BEGIN CERTIFICATE-----/ {if (NR > 1) print cert; cert = $0; next} {cert = cert "\n" $0}' 0001_chain.pem > "$REPOSITORY_DIR/server-authentication/$1.crt"
	sudo rm 000*.pem
}
generate-certificate "compact-orb.ovh"
generate-certificate "compact-orb.ovh-rsa"
generate-certificate "*.compact-orb.ovh"
generate-certificate "*.compact-orb.ovh-rsa"
echo -e $COMPACT_ORB_KEY > $REPOSITORY_DIR/server-authentication/compact-orb.key
echo -e $COMPACT_ORB_RSA_KEY > $REPOSITORY_DIR/server-authentication/compact-orb-rsa.key
deactivate
rm --recursive venv

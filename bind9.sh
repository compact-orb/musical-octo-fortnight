#!/usr/bin/bash

#Bash strict mode
echo 'Bash strict mode'
set -euo pipefail
IFS=$'\n\t'

#Install required bundles
echo 'Install required bundles'
swupd bundle-add c-basic devpkg-libuv devpkg-nghttp2 devpkg-userspace-rcu git

#Clean swupd cache
echo 'Clean swupd cache'
swupd clean --all

#Build in /tmp
echo 'Build in /tmp'
cd /tmp

#Download bind9
echo 'Download bind9'
curl --output Archive.tar.gz https://gitlab.isc.org/isc-projects/bind9/-/archive/v9.21.2/bind9-v9.21.2.tar.gz
tar --extract --file=Archive.tar.gz
rm Archive.tar.gz
cd bind9-*

#Configure bind9
echo 'Configure bind9'
autoreconf --install
CC=clang CFLAGS='-O3 -flto' LDFLAGS='-fuse-ld=lld' ./configure

#Build bind9
echo 'Build bind9'
make --jobs=$(nproc)

#Install bind9
echo 'Install bind9'
make install

#!/usr/bin/bash

#Bash strict mode
set -euo pipefail
IFS=$'\n\t'

#Install required packages
swupd bundle-add c-basic devpkg-libuv devpkg-nghttp2 devpkg-userspace-rcu git

#Build in /tmp
cd /tmp

#Download bind9
curl --output Archive.tar.gz https://gitlab.isc.org/isc-projects/bind9/-/archive/v9.21.2/bind9-v9.21.2.tar.gz
tar --extract --file=Archive.tar.gz
rm Archive.tar.gz
cd bind9-*

#Configure bind9
autoreconf --install
CC=clang CFLAGS='-O3 -flto' -LDFLAGS='-fuse-ld=lld' ./configure

#Build bind9
make --jobs=$(nproc)

#Install bind9
make install

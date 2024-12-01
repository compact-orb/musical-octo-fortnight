#!/usr/bin/bash

#Bash strict mode
set -euo pipefail
IFS=$'\n\t'

#Install required bundles
echo '——Install required bundles——'
swupd bundle-add c-basic

#Clean swupd cache
echo '——Clean swupd cache——'
swupd clean --all

#Build in /tmp
echo '——Build in /tmp——'
cd /tmp

#Download mimalloc
echo '——Download mimalloc——'
curl --output Archive.tar.gz --location https://github.com/microsoft/mimalloc/archive/refs/tags/v2.1.7.tar.gz
tar --extract --file=Archive.tar.gz
rm Archive.tar.gz
cd mimalloc-*

#Configure mimalloc
echo '——Configure mimalloc——'
CC=clang CFLAGS='-O3 -flto=thin' CXX=clang++ CXXFLAGS=$CFLAGS LDFLAGS='-fuse-ld=lld' cmake --install-prefix /opt/musical-octo-fortnight/usr -DCMAKE_BUILD_TYPE=Release .

#Build mimalloc
cmake --build . --parallel $(nproc)

#Install mimalloc   
cmake --install .

#!/usr/bin/bash

#Bash strict mode
set -euo pipefail
IFS=$'\n\t'

#Install required bundles
echo '——Install required bundles——'
swupd bundle-add c-basic devpkg-libcap devpkg-libuv devpkg-nghttp2 devpkg-openssl devpkg-userspace-rcu

#Clean swupd cache
echo '——Clean swupd cache——'
swupd clean --all

#Build in /tmp
echo '——Build in /tmp——'
cd /tmp

#Download bind9
echo '——Download bind9——'
curl --output Archive.tar.gz https://gitlab.isc.org/isc-projects/bind9/-/archive/v9.21.2/bind9-v9.21.2.tar.gz

#Extract bind9
echo '——Extract bind9——'
tar --extract --file=Archive.tar.gz
cd bind9-*

#Configure bind9 with profile generation
echo '——Configure bind9 with profile generation——'
function configure {
    autoreconf --install
    CC=clang CFLAGS="-O3 -flto=thin $1" LDFLAGS='-fuse-ld=lld' ./configure --prefix=/opt/musical-octo-fortnight/usr
}
configure '-fprofile-instr-generate=/tmp/profile.profraw'

#Build bind9 with profile generation
echo '——Build bind9 with profile generation——'
make --jobs=$(nproc)

#Install bind9 with profile generation
echo '——Install bind9 with profile generation——'
make install
cd ..
rm --recursive --force bind9-*

#Run test workload
echo '——Run test workload——'
/opt/musical-octo-fortnight/usr/sbin/named -v #Placeholder
llvm-profdata merge -output=/tmp/profile.profdata /tmp/profile.profraw
rm --force /tmp/profile.profraw

#Uninstall bind9 with profile generation
echo '——Uninstall bind9 with profile generation——'
rm --recursive --force /opt/musical-octo-fortnight/usr

#Extract bind9
echo '——Extract bind9——'
tar --extract --file=Archive.tar.gz
cd bind9-*

#Configure bind9 with profile use
echo '——Configure bind9 with profile use——'
configure '-fprofile-instr-use=/tmp/profile.profdata'

#Build bind9 with profile use
echo '——Build bind9 with profile use——'
make --jobs=$(nproc)

#Install bind9 with profile use
echo '——Install bind9 with profile use——'
make install
cd ..
rm --recursive --force bind9-*

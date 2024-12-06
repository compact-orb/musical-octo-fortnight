#!/usr/bin/bash

#Modified unofficial Bash strict mode
set -eo pipefail
IFS=$'\n\t'

#Use global profile
. /usr/share/defaults/etc/profile

#Build in /tmp
echo '——Build in /tmp——'
BUILD_DIR=/tmp
cd $BUILD_DIR

#Install required bundles
echo '——Install required bundles——'
swupd bundle-add c-basic
swupd clean --all
curl --fail --output intel-dpcpp-cpp-compiler-2025.0.3.9.sh https://registrationcenter-download.intel.com/akdlm/IRC_NAS/1cac4f39-2032-4aa9-86d7-e4f3e40e4277/intel-dpcpp-cpp-compiler-2025.0.3.9.sh
chmod +x intel-dpcpp-cpp-compiler-2025.0.3.9.sh
./intel-dpcpp-cpp-compiler-2025.0.3.9.sh -a --eula accept --silent
rm --force intel-dpcpp-cpp-compiler-2025.0.3.9.sh

#Set Intel DPC++ environment variables
echo '——Set Intel DPC++ environment variables——'
source /opt/intel/oneapi/setvars.sh --include-intel-llvm

#Download mimalloc
echo '——Download mimalloc——'
curl --fail --output Archive.tar.gz --location https://github.com/microsoft/mimalloc/archive/refs/tags/v2.1.7.tar.gz

#Extract mimalloc
echo '——Extract mimalloc——'
tar --extract --file=Archive.tar.gz
rm --force Archive.tar.gz
cd mimalloc-*

#Configure mimalloc
echo '——Configure mimalloc——'
CC=icx CFLAGS="$(echo "$CFLAGS" | sed 's/-\(feliminate-unused-debug-types\|ffat-lto-objects\|ftree-loop-distribute-patterns\|mrelax-cmpxchg-loop\)//g') -fcf-protection -flto=thin -fpic -fpie -fstack-clash-protection -fstack-protector-strong -ipo -march=x86-64-v3 -mtune=haswell" CXX=icpx CXXFLAGS="$(echo "$CXXFLAGS" | sed 's/-\(Wl,--enable-new-dtags\|feliminate-unused-debug-types\|ffat-lto-objects\|ftree-loop-distribute-patterns\|mrelax-cmpxchg-loop\)//g') -D_GLIBCXX_ASSERTIONS -fcf-protection -flto=thin -fpic -fpie -fstack-clash-protection -fstack-protector-strong -ipo -march=x86-64-v3 -mtune=haswell" LDFLAGS='-Wl,--as-needed -fuse-ld=lld' cmake --install-prefix /opt/musical-octo-fortnight/usr -DCMAKE_BUILD_TYPE=Release -DMI_SECURE=ON .

#Build mimalloc
echo '——Build mimalloc——'
cmake --build . --parallel $(nproc)

#Install mimalloc
echo '——Install mimalloc——'
cmake --install .
cd ..
rm --recursive --force mimalloc-*

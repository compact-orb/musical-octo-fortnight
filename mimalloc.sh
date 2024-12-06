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
export CC=clang CFLAGS='-O3 -flto=thin' CXX=clang++ CXXFLAGS=$CFLAGS LDFLAGS='-fuse-ld=lld'
cmake --install-prefix /opt/musical-octo-fortnight/usr -DCMAKE_BUILD_TYPE=Release .

#Build mimalloc
cmake --build . --parallel $(nproc)

#Install mimalloc   
cmake --install .


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

#Build in /tmp
echo '——Build in /tmp——'
cd /tmp

#Download mimalloc
echo '——Download mimalloc——'
curl --fail --output Archive.tar.gz --location https://github.com/microsoft/mimalloc/archive/refs/tags/v2.1.7.tar.gz

#Extract mimalloc
echo '——Extract mimalloc——'
tar --extract --file=Archive.tar.gz
rm --force Archive.tar.gz
cd mimalloc-*

#Configure mimalloc with profile generation
echo '——Configure mimalloc with profile generation——'
function configure {
	CC=icx CFLAGS="$(echo "$CFLAGS" | sed 's/-\(feliminate-unused-debug-types\|ffat-lto-objects\|ftree-loop-distribute-patterns\|mrelax-cmpxchg-loop\)//g') -fcf-protection -flto=thin -fpic -fpie -fstack-clash-protection -fstack-protector-strong -ipo -march=x86-64-v3 -mtune=haswell $1" LDFLAGS='-Wl,--as-needed -Wl,-pie -fuse-ld=lld -rtlib=compiler-rt' cmake --install-prefix /opt/musical-octo-fortnight/usr -DCMAKE_BUILD_TYPE=Release .
}
configure "-fprofile-instr-generate=$BUILD_DIR/profile.profraw"

#Build bind9 with profile generation
echo '——Build bind9 with profile generation——'
make --jobs=$(nproc)

#Install bind9 with profile generation
echo '——Install bind9 with profile generation——'
make install
cd ..
rm --recursive --force bind9-*

#Install test
echo '——Install test——'


#Run test
echo '——Run test——'
/opt/musical-octo-fortnight/usr/sbin/named -f &
NAMED_PID=$!
sleep 2
dns_lookup() {
	echo "$DOMAINS" | while read -r domain
	do
		/opt/musical-octo-fortnight/usr/bin/dig @127.0.0.1 a $@ "$domain" &>/dev/null
		/opt/musical-octo-fortnight/usr/bin/dig @127.0.0.1 aaaa $@ "$domain" &>/dev/null
		/opt/musical-octo-fortnight/usr/bin/dig @::1 a $@ "$domain" &>/dev/null
		/opt/musical-octo-fortnight/usr/bin/dig @::1 aaaa $@ "$domain" &>/dev/null
	done
}
dns_lookup +dnssec
dns_lookup +dnssec +https
dns_lookup +dnssec +tls
kill $NAMED_PID
unset NAMED_PID
rm --recursive --force /opt/musical-octo-fortnight/usr/etc /tmp/certificate.pem /tmp/document.csv /tmp/key.key /tmp/named /tmp/named.root /tmp/oisd_big_rpz.txt
llvm-profdata merge -output=profile.profdata profile.profraw
rm --force ../profile.profraw

#Uninstall bind9 with profile generation
echo '——Uninstall bind9 with profile generation——'
rm --recursive --force /opt/musical-octo-fortnight/usr

#Extract bind9
echo '——Extract bind9——'
tar --extract --file=Archive.tar.gz
rm --force Archive.tar.gz
cd bind9-*

#Configure bind9 with profile use
echo '——Configure bind9 with profile use——'
configure "-fprofile-instr-use=$BUILD_DIR/profile.profdata"

#Build bind9 with profile use
echo '——Build bind9 with profile use——'
make --jobs=$(nproc)

#Install bind9 with profile use
echo '——Install bind9 with profile use——'
make install
rm --force ../profile.profdata
cd ..
rm --recursive --force bind9-*

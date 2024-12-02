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
	CC=clang CFLAGS="-O3 -flto=thin -march=x86-64-v3 -mtune=haswell -pipe $1" LDFLAGS='-fuse-ld=lld' ./configure --prefix=/opt/musical-octo-fortnight/usr
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

#Install test
echo $COMPACT_ORB_ECC_KEY > /tmp/key.key
echo $COMPACT_ORB_ECC_PEM > /tmp/certificate.pem
curl --output /tmp/named.root https://www.internic.net/domain/named.root
curl --output /tmp/oisd_big_rpz.txt https://big.oisd.nl/rpz
echo '2mdn.net
3gppnetwork.org
3lift.com
a-msedge.net
a2z.com
aaplimg.com
adform.net
adnxs.com
adobe.com
adobe.io
adsafeprotected.com
adsrvr.org
adtrafficquality.google
akadns.net
akamai.net
akamaiedge.net
akamaihd.net
akamaized.net
alicdn.com
aliyuncs.com
allawnos.com
amazon-adsystem.com
amazon.com
amazon.dev
amazonalexa.com
amazonaws.com
ampproject.org
android.com
app-analytics-services.com
app-measurement.com
appcenter.ms
apple-dns.net
apple.com
applovin.com
appsflyer.com
appsflyersdk.com
atomile.com
avast.com
avcdn.net
azure.com
azureedge.net
baidu.com
bidswitch.net
bing.com
branch.io
bytefcdn-oversea.com
bytefcdn-ttpeu.com
byteoversea.com
byteoversea.net
capcutapi.com
casalemedia.com
cdn-apple.com
cdn77.org
cdninstagram.com
clarity.ms
cloudflare-dns.com
cloudflare.com
cloudflare.net
cloudfront.net
crashlytics.com
creativecdn.com
criteo.com
criteo.net
demdex.net
digicert.com
dns.google
dotomi.com
doubleclick.net
doubleverify.com
douyincdn.com
dropbox.com
edgekey.net
epicgames.com
example.com
facebook.com
facebook.net
fastly-edge.com
fastly.net
fbcdn.net
firetvcaptiveportal.com
gamepass.com
ggpht.com
github.com
gmail.com
google-analytics.com
google.com
google.com.br
googleadservices.com
googleapis.com
googlesyndication.com
googletagmanager.com
googletagservices.com
googleusercontent.com
googlevideo.com
grammarly.com
gstatic.com
gvt1.com
gvt2.com
heytapdl.com
ibyteimg.com
icloud.com
id5-sync.com
inmobi.com
inner-active.mobi
instagram.com
isnssdk.com
jsdelivr.net
kwai.net
launchdarkly.com
lencr.org
liadm.com
linkedin.com
live.com
media-amazon.com
media.net
microsoft.com
microsoftonline.com
mikrotik.com
miui.com
msedge.net
msftconnecttest.com
msftncsi.com
msn.com
mtgglobals.com
mzstatic.com
netflix.com
nflximg.com
nflxso.net
nist.gov
nr-data.net
ntp.org
office.com
office.net
office365.com
one.one
openx.net
opera.com
outbrain.com
outlook.com
pangle.io
pinterest.com
pki.goog
playstation.net
pubmatic.com
qlivecdn.com
qq.com
rbxcdn.com
reddit.com
roblox.com
rocket-cdn.com
roku.com
root-servers.net
rubiconproject.com
samsung.com
samsungcloud.com
samsungcloudsolution.com
samsungqbe.com
sc-cdn.net
scorecardresearch.com
sentry.io
shalltry.com
sharepoint.com
sharethrough.com
skype.com
smartadserver.com
snapchat.com
spotify.com
steamserver.net
taboola.com
taobao.com
tiktok.com
tiktokcdn-eu.com
tiktokcdn-us.com
tiktokcdn.com
tiktokv.com
tiktokv.us
tp-link.com
trafficmanager.net
ttlivecdn.com
twimg.com
twitter.com
ubuntu.com
ui.com
unity3d.com
vungle.com
whatsapp.com
whatsapp.net
wikipedia.org
windows.com
windows.net
windowsupdate.com
xboxlive.com
xiaomi.com
yahoo.com
yandex.net
yandex.ru
youtube.com
ytimg.com
yximgs.com
zoom.us' > /tmp/document.csv
mkdir /tmp/named
mkdir /opt/musical-octo-fortnight/usr/etc
echo '——Install test——'
echo 'tls ecc {
		key-file "/tmp/key.key";
		cert-file "/tmp/certificate.pem";
};
options {
		directory "/tmp/named";
		version "not currently available";
		recursion no;
		listen-on { ::1; };
		listen-on-v6 { ::1; };
		dnssec-validation auto;
		listen-on tls ecc { ::1; };
		listen-on-v6 tls ecc { ::1; };
		listen-on tls ecc http default { ::1; };
		listen-on-v6 tls ecc http default { ::1; };
		response-policy {
				zone rpz.oisd.nl.;
		};
		forwarders {
                8.8.8.8;
                8.8.4.4;
        };
        forward only;
};
zone rpz.oisd.nl. {
		type primary;
		file "/tmp/oisd_big_rpz.txt";
		allow-query { none; };
		allow-transfer { none; };
};' > /opt/musical-octo-fortnight/usr/etc/named.conf

#Run test
echo '——Run test——'
/opt/musical-octo-fortnight/usr/sbin/named -f &
NAMED_PID=$!
sleep 16
dns_lookup() {
	/opt/musical-octo-fortnight/usr/bin/dig @::1 a $1 "$domain"
	/opt/musical-octo-fortnight/usr/bin/dig @::1 aaaa $1 "$domain"
}
while read domain
do
	dns_lookup +tries=1024
done < /tmp/document.csv
while read domain
do
	dns_lookup +https +tries=1024
done < /tmp/document.csv
while read domain
do
	dns_lookup +tls +tries=1024
done < /tmp/document.csv
kill --signal=SIGINT $NAMED_PID
unset NAMED_PID
rm --recursive --force /opt/musical-octo-fortnight/usr/etc /tmp/certificate.pem /tmp/document.csv /tmp/key.key /tmp/named /tmp/named.root /tmp/oisd_big_rpz.txt
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
rm --force /tmp/profile.profdata
cd ..
rm --recursive --force bind9-*

#Clean up
echo '——Clean up——'
rm --force Archive.tar.gz

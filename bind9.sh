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
curl --fail --output Archive.tar.gz https://gitlab.isc.org/isc-projects/bind9/-/archive/v9.21.2/bind9-v9.21.2.tar.gz

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
echo '-----BEGIN EC PARAMETERS-----
BggqhkjOPQMBBw==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIIXQEDKf3CdxmcIlucNIgaoMfBFIKZ9Jr3Sv1f8m/SB0oAoGCCqGSM49
AwEHoUQDQgAEHZSrrwnZonun04nRD6lDlkKNdujRf9YePBGU3rE9vPfQ/vRLsMAP
coKguPSUDo8ZLHrJsI/ZUt0iMN29XKbgRQ==
-----END EC PRIVATE KEY-----' > /tmp/key.key
echo '-----BEGIN CERTIFICATE-----
MIIB3jCCAYWgAwIBAgIUfR70H8RLkOqgTTXooV+z/jAFu8EwCgYIKoZIzj0EAwIw
RTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoMGElu
dGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yNDEyMDIwNTA2MjNaFw0yNDEyMDMw
NTA2MjNaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYD
VQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwWTATBgcqhkjOPQIBBggqhkjO
PQMBBwNCAAQdlKuvCdmie6fTidEPqUOWQo126NF/1h48EZTesT2899D+9EuwwA9y
gqC49JQOjxksesmwj9lS3SIw3b1cpuBFo1MwUTAdBgNVHQ4EFgQUABV/xiBYnZxy
Lez3d/IL7tTEgzswHwYDVR0jBBgwFoAUABV/xiBYnZxyLez3d/IL7tTEgzswDwYD
VR0TAQH/BAUwAwEB/zAKBggqhkjOPQQDAgNHADBEAiAU6oMXxtwigklpoSklqIEZ
n4q5eQifvMSo4SzLJDYczwIgfEqJYvSRTqcwhzCCnXSzJ7CHbnqKpx0h7d5jNNWV
Xrw=
-----END CERTIFICATE-----' > /tmp/certificate.pem
curl --fail --output /tmp/named.root https://www.internic.net/domain/named.root
curl --fail --output /tmp/oisd_big_rpz.txt https://big.oisd.nl/rpz
#Data from https://radar.cloudflare.com/domains
#Top 1000 domains
#Updated: Dec 2, 2024
echo '163.com
1drv.com
1rx.io
2mdn.net
2miners.com
33across.com
360.cn
360safe.com
360yield.com
3gppnetwork.org
3lift.com
4dex.io
a-mo.net
a-msedge.net
a2z.com
aadrm.com
aaplimg.com
accuweather.com
acrobat.com
acronis.com
acuityplatform.com
ad-delivery.net
ad-score.com
ad.gt
adaether.com
adblockplus.org
adentifi.com
adform.net
adgrx.com
adguard.com
adingo.jp
adition.com
adjust.com
adkernel.com
admanmedia.com
adnxs-simple.com
adnxs.com
adobe.com
adobe.io
adobedc.net
adobedtm.com
adobelogin.com
adobess.com
adriver.ru
adroll.com
adrta.com
ads-twitter.com
adsafeprotected.com
adscale.de
adsco.re
adsmoloco.com
adsrvr.org
adtelligent.com
adtng.com
adtrafficquality.google
afafb.com
afcdn.net
agkn.com
agora.io
aibixby.com
aiv-cdn.net
aiv-delivery.net
aka.ms
akadns.net
akamai.com
akamai.net
akamaiedge.net
akamaihd.net
akamaized.net
akaquill.net
akstat.io
al-array.com
algolia.net
alibaba.com
alibabadns.com
alicdn.com
aliexpress.com
alipay.com
aliyun.com
aliyuncs.com
allawnos.com
allawntech.com
alphonso.tv
amap.com
amazon-adsystem.com
amazon.co.uk
amazon.com
amazon.de
amazon.dev
amazonalexa.com
amazonaws.com
amazontrust.com
amazonvideo.com
amemv.com
amp-endpoint2.com
amp-endpoint3.com
amplitude.com
ampproject.org
amung.us
android.com
aniview.com
anydesk.com
anythinktech.com
ap4r.com
app-analytics-services-att.com
app-analytics-services.com
app-measurement.com
appcenter.ms
appier.net
apple-cloudkit.com
apple-dns.net
apple.com
apple.news
applovin.com
applvn.com
appsflyer.com
appsflyersdk.com
appspot.com
arin.net
arubanetworks.com
atlassian.com
atlassian.net
atomile.com
attn.tv
autodesk.com
av380.net
avast.com
avcdn.net
avira.com
avsxappcaptiveportal.com
awardpongsur.org
aws.dev
awswaf.com
ax-msedge.net
azure-api.net
azure-devices.net
azure.com
azure.net
azureedge.net
azurefd.net
azurewebsites.net
b-cdn.net
b-msedge.net
baidu.com
bamgrid.com
battle.net
bazaarvoice.com
bb.com.br
belkin.com
betweendigital.com
beyla.site
bfmio.com
bidmachine.io
bidr.io
bidswitch.net
bigo.sg
bigolive.tv
bilibili.com
binance.com
bing.com
bing.net
bitdefender.com
bitdefender.net
blizzard.com
blockdh100b.net
blockdh100c.co
blogspot.com
bluekai.com
booking.com
bootstrapcdn.com
bounceexchange.com
branch.io
brave.com
braze.com
braze.eu
browser-intake-datadoghq.com
bt.co
btloader.com
bttrack.com
bugsnag.com
bytedance.com
byteeffecttos-g.com
bytefcdn-oversea.com
bytefcdn-ttpeu.com
byteglb.com
byteintl.com
byteoversea.com
byteoversea.net
bytetcdn.com
caelumbee.co.uk
camelopardalisbee.com
canva.com
capcut.com
capcutapi.com
casalemedia.com
cdn-apple.com
cdn.house
cdn20.com
cdn77.org
cdngslb.com
cdnhwc1.com
cdnhwc3.com
cdninstagram.com
cedexis-radar.net
cedexis-test.com
cedexis.com
cedexis.net
centrastage.net
chartbeat.com
chartbeat.net
chartboost.com
chatgpt.com
checkpoint.com
chocopinglate.org
cisco.com
clarity.ms
clevertap-prod.com
cloud.microsoft
cloudapp.net
cloudflare-dns.com
cloudflare.com
cloudflare.net
cloudflareclient.com
cloudflareinsights.com
cloudfront.net
cloudfunctions.net
cloudinary.com
cloudlinks.cn
cloudsink.net
cnn.com
coinbase.com
coingecko.com
coinmarketcap.com
coloros.com
comcast.net
comodoca.com
company-target.com
connatix.com
contentsquare.net
contextweb.com
conviva.com
cookiebot.com
cookielaw.org
cootlogix.com
cqloud.com
cquotient.com
crashlytics.com
crazyegg.com
creativecdn.com
criteo.com
criteo.net
crwdcntrl.net
cspserver.net
cursor.sh
cxense.com
dalyfeds.com
datadoghq.com
datadome.co
datto.com
dbankcdn.cn
dbankcdn.com
dbankcloud.cn
dbankcloud.com
ddns.net
deepintent.com
deepl.com
dell.com
deltaork.com
demdex.net
digicert.com
digitaloceanspaces.com
discomax.com
discord.com
discord.gg
discord.media
discordapp.com
discordapp.net
disqus.com
dns.google
docker.com
docker.io
doppiocdn.net
dotomi.com
doubleclick.net
doubleverify.com
douyincdn.com
douyinliving.com
douyinvod.com
dropbox-dns.com
dropbox.com
dropboxapi.com
dtscout.com
dual-s-msedge.net
duckdns.org
duckduckgo.com
duolingo.com
dutils.com
dv.tech
dwin1.com
dynamicyield.com
dynatrace.com
dyndns.org
dzen.ru
e-msedge.net
e-planning.net
ea.com
easy4ipcloud.com
ebay.com
edgekey.net
edgesuite.net
elasticbeanstalk.com
emxdgt.com
entrust.net
epicgames.com
epicgames.dev
erome.com
eset.com
espn.com
espncdn.com
eu-1-id5-sync.com
eu.org
eum-appdynamics.com
everesttech.net
evergage.com
example.com
example.org
exelator.com
exp-tas.com
eyeota.net
ezvizlife.com
facebook.com
facebook.net
fast.com
fastclick.net
fastly-edge.com
fastly.net
fb.com
fbcdn.net
fbpigeon.com
fbsbx.com
feednews.com
fengpongshu.com
firebaseio.com
firefox.com
firetvcaptiveportal.com
flashtalking.com
flurry.com
fontawesome.com
footprintdns.com
force.com
forter.com
freefiremobile.com
fullstory.com
fwmrm.net
fyber.com
game-sdk.com
gameanalytics.com
gamepass.com
garena.com
gastecnologia.com.br
gcdn.co
geoedge.be
geotrust.com
ggblueshark.com
ggpht.com
giphy.com
github.com
github.io
githubusercontent.com
glance-cdn.com
glanceapis.com
globalsign.com
globo.com
glpals.com
gmail.com
go-mpulse.net
godaddy.com
google-analytics.com
google.ca
google.cn
google.co.id
google.co.in
google.co.jp
google.co.uk
google.com
google.com.au
google.com.br
google.com.hk
google.de
google.fr
google.ru
google.us
googleadservices.com
googleapis.cn
googleapis.com
googlesyndication.com
googletagmanager.com
googletagservices.com
googleusercontent.com
googlevideo.com
googlezip.net
gos-gsp.io
goskope.com
grafana.com
grammarly.com
grammarly.io
gravatar.com
gstatic.com
gumgum.com
gvt1.com
gvt2.com
gvt3.com
harman.com
hcaptcha.com
here.com
herokuapp.com
heytapdl.com
heytapmobi.com
heytapmobile.com
hhf123dcd.com
hicloud.com
hihonorcloud.com
hik-connect.com
hisavana.com
home-assistant.io
hotjar.com
hotjar.io
hotmail.com
hoyoverse.com
hp.com
huawei.com
hubspot.com
hulu.com
huntress.io
i18n-pglstatp.com
ibytedtos.com
ibyteimg.com
icanhazip.com
icloud-content.com
icloud.com
icloud.com.cn
id5-sync.com
ieee.org
igamecj.com
igodigital.com
imkirh.com
imoim.net
imolive2.com
imrworldwide.com
indexww.com
ingage.tech
inkuai.com
inmobi.com
inmobicdn.net
inner-active.mobi
innovid.com
instabug.com
instagram.com
int08h.com
intel.com
intelbras.com.br
intentiq.com
intercom.io
intuit.com
ip-api.com
ipify.org
ipinfo.io
ipredictive.com
isappcloud.com
isnssdk.com
iterable.com
ixigua.com
jetbrains.com
jhkkjkj.com
joinhoney.com
jquery.com
jsdelivr.net
jtvnw.net
jwplayer.com
jwpltx.com
kargo.com
kaspersky-labs.com
kaspersky.com
keplr.app
klaviyo.com
ks-cdn.com
kuaishou.com
kueezrtb.com
kwai-pro.com
kwai.com
kwai.net
kwaicdn.com
kwaipros.com
kwcdn.com
kwimgs.com
l-msedge.net
larkplayerapp.com
launchdarkly.com
leiniao.com
lencr.org
lenovo.com
lge.com
lgtvcommon.com
lgtvsdp.com
liadm.com
licdn.com
life360.com
liftoff-creatives.io
liftoff.io
lijit.com
like.video
line-apps.com
linkedin.com
litix.io
live.com
live.net
livechatinc.com
llnwi.net
loopme.me
ltwebstatic.com
magsrv.com
mail.ru
mapbox.com
marketingcloudapis.com
mathtag.com
mcafee.com
me.com
media-amazon.com
media.net
mediago.io
mediatek.com
mediavine.com
meethue.com
mega.co.nz
meraki.com
mercadolibre.com
metamask.io
mfadsrvr.com
mgid.com
mi-img.com
mi.com
microsoft.com
microsoft.us
microsoftapp.net
microsoftonline.com
microsoftpersonalcontent.com
mikrotik.com
miniclippt.com
minutemedia-prebid.com
miui.com
miwifi.com
mixpanel.com
mlstatic.com
mmcdn.com
mmechocaptiveportal.com
mmstat.com
moatads.com
mob.com
mobiuspace.net
moengage.com
moloco.com
mookie1.com
mosspf.com
mossru.com
mozgcp.net
mozilla.com
mozilla.net
mozilla.org
mparticle.com
msauth.net
msecnd.net
msedge.net
msftauth.net
msftconnecttest.com
msftncsi.com
msidentity.com
msn.com
mtgglobals.com
myhuaweicloud.com
mynetname.net
myqcloud.com
mythad.com
mzstatic.com
n-able.com
nakheelteam.cc
naver.com
ne.jp
nel.goog
nelreports.net
nest.com
netflix.com
netflix.net
netgear.com
newrelic.com
nextmillmedia.com
nflxext.com
nflximg.com
nflximg.net
nflxso.net
nflxvideo.net
nintendo.net
nist.gov
no-ip.com
norton.com
notion.so
nr-data.net
ntp.org
ntppool.org
nubank.com.br
nvidia.com
oculus.com
office.com
office.net
office365.com
okcdn.ru
okx.com
omnitagjs.com
omtrdc.net
one.one
onedrive.com
onelink.me
onenote.com
onenote.net
onesignal.com
onetag-sys.com
onetrust.com
onetrust.io
online-metrix.net
onmicrosoft.com
openai.com
opendns.com
openx.net
opera-api.com
opera-api2.com
opera.com
opera.software
oppomobile.com
optimizely.com
oracle.com
oraclecloud.com
orbsrv.com
outbrain.com
outbrainimg.com
outlook.com
overwolf.com
ovscdns.com
ovscdns.net
pages.dev
palmplaystore.com
paloaltonetworks.com
pandora.com
pangle.io
parsely.com
paypal.com
peacocktv.com
pendo.io
permutive.app
permutive.com
phantom.app
phicdn.net
phncdn.com
pinimg.com
pinterest.com
piojm.tech
pki.goog
playstation.com
playstation.net
plex.tv
pluto.tv
postrelease.com
presage.io
primis.tech
privacy-center.org
privacymanager.io
privacysandboxservices.com
prodregistryv2.org
pstatp.com
pubmatic.com
pubmnet.com
pubnative.net
pullcf.com
pullcm.com
pusher.com
pv-cdn.net
pvp.net
qlivecdn.com
qq.com
qualtrics.com
quantcount.com
quantserve.com
quantummetric.com
quickconnect.to
rainberrytv.com
rapid7.com
ravm.tv
rayjump.com
rbxcdn.com
reasonsecurity.com
recaptcha.net
redd.it
reddit.com
redditmedia.com
redditstatic.com
repocket.com
revcontent.com
rfihub.com
richaudience.com
ring.com
rings.solutions
riotcdn.net
riotgames.com
rlcdn.com
roblox.com
rocket-cdn.com
roku.com
root-servers.net
rtmark.net
rubiconproject.com
s-msedge.net
sacdnssedge.com
safebrowsing.apple
safedk.com
salesforce.com
salesforceliveagent.com
samba.tv
samsung.com
samsungacr.com
samsungapps.com
samsungcloud.com
samsungcloud.tv
samsungcloudsolution.com
samsungcloudsolution.net
samsungdm.com
samsungelectronics.com
samsungiotcloud.com
samsungnyc.com
samsungosp.com
samsungqbe.com
sascdn.com
sbixby.com
sc-cdn.net
sc-gw.com
sc-static.net
scdn.co
scene7.com
scorecardresearch.com
script.ac
sectigo.com
secu100.net
seedtag.com
segment.com
segment.io
sendgrid.net
sentinelone.net
sentry.io
servenobid.com
service-now.com
sfx.ms
sgsnssdk.com
shalltry.com
sharepoint.com
sharethis.com
sharethrough.com
shein.com
shifen.com
shopee.co.id
shopee.com.br
shopee.io
shopeemobile.com
shopify.com
shopifysvc.com
signal.org
simpli.fi
singular.net
sitescout.com
skype.com
slack.com
slackb.com
smaato.net
smadex.com
smartadserver.com
smartthings.com
smilewanted.com
snackvideo.in
snapchat.com
snapkit.com
snaptube.app
snssdk.com
socdm.com
sogou.com
sonicwall.com
sonobi.com
sophos.com
sophosxl.net
soundcloud.com
spamhaus.org
spbycdn.com
speedtest.net
split.io
spo-msedge.net
spot.im
spotify.com
spotifycdn.com
springserve.com
srmdata-us.com
ssl-images-amazon.com
ssl.com
stackadapt.com
starlink.com
starmakerstudios.com
startappservice.com
static.microsoft
statuspage.io
steamcommunity.com
steamcontent.com
steampowered.com
steamserver.net
steamstatic.com
stickyadstv.com
stripchat.com
stripe.com
strpst.com
sunnypingdrink.com
supercell.com
supersonicads.com
surfshark.com
susercontent.com
svc.ms
svcmot.com
swiftkey.com
symcb.com
syncthing.net
synology.com
t-msedge.net
t.co
taboola.com
taobao.com
tapad.com
tapjoy.com
target.com
teads.tv
tealiumiq.com
teamviewer.com
telegram.org
telephony.goog
temu.com
tencent-cloud.net
tenda.com.cn
terabox.com
thejeu.com
themoviedb.org
tiktok.com
tiktokcdn-eu.com
tiktokcdn-us.com
tiktokcdn.com
tiktokv.com
tiktokv.eu
tiktokv.us
tiqcdn.com
tizen.org
tlivepush.com
tp-link.com
tplinkcloud.com
tplinknbu.com
tq-tungsten.com
tradingview.com
tradplusad.com
trafficjunky.net
trafficmanager.net
transmissionbt.com
transsion-os.com
tremorhub.com
trendmicro.com
tribalfusion.com
truecaller.com
trustarc.com
truste.com
trustpilot.com
tsyndicate.com
ttdns2.com
ttlivecdn.com
ttoverseaus.net
ttvnw.net
ttwstatic.com
turn.com
twilio.com
twimg.com
twitch.tv
twitter.com
tynt.com
typekit.com
typekit.net
uber.com
ubi.com
ubnt.com
ubuntu.com
ucweb.com
ueiwsp.com
ui.com
uisp.com
umeng.com
undertone.com
unifi-ai.com
unity3d.com
unmsapp.com
unpkg.com
unrulymedia.com
uol.com.br
urbanairship.com
useinsider.com
userapi.com
usercentrics.eu
usertrust.com
usgovcloudapi.net
utorrent.com
v-videoapp.com
verisign.com
verkada.com
viber.com
vidaahub.com
vidoomy.com
vimeo.com
vimeocdn.com
virtualearth.net
visualstudio.com
vivo.com.cn
vivoglobal.com
vk.com
vmware.com
volcfcdndvs.com
vtwenty.com
vungle.com
w3.org
w55c.net
wac-msedge.net
walmart.com
wattpad.com
wbx2.com
weather.com
webex.com
webrootcloudav.com
wechat.com
weerrhoop.cc
whatsapp.com
whatsapp.net
wikimedia.org
wikipedia.org
windows.com
windows.net
windowsupdate.com
withgoogle.com
wordpress.com
worldfcdn2.com
wp.com
wpadmngr.com
wps.com
wsdvs.com
wshareit.com
wynd.network
wyzecam.com
x.com
xboxlive.com
xhamster.com
xhcdn.com
xiaohongshu.com
xiaomi.com
xiaomi.net
xnxx-cdn.com
xvideos-cdn.com
xvideos.com
ya.ru
yahoo.co.jp
yahoo.com
yahoodns.net
yammer.com
yandex.com
yandex.net
yandex.ru
yandexadexchange.net
yastatic.net
yellowblue.io
yieldmo.com
yimg.com
yimg.jp
yotpo.com
youboranqs01.com
youtube-nocookie.com
youtube.com
ys7.com
ytimg.com
yximgs.com
zdassets.com
zemanta.com
zendesk.com
zeotap.com
zijieapi.com
zoho.com
zoom.us
zopim.com
zpath.net' > /tmp/document.csv
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
	recursion yes;
	listen-on { 127.0.0.1; };
	listen-on-v6 { ::1; };
	dnssec-validation auto;
	listen-on tls ecc { 127.0.0.1; };
	listen-on-v6 tls ecc { ::1; };
	listen-on tls ecc http default { 127.0.0.1; };
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
sleep 2
dns_lookup() {
	while read -r domain
	do
		/opt/musical-octo-fortnight/usr/bin/dig @127.0.0.1 a $@ "$domain" &>/dev/null
		/opt/musical-octo-fortnight/usr/bin/dig @127.0.0.1 aaaa $@ "$domain" &>/dev/null
		/opt/musical-octo-fortnight/usr/bin/dig @::1 a $@ "$domain" &>/dev/null
		/opt/musical-octo-fortnight/usr/bin/dig @::1 aaaa $@ "$domain" &>/dev/null
	done < /tmp/document.csv
}
dns_lookup +dnssec
dns_lookup +dnssec +https
dns_lookup +dnssec +tls
kill $NAMED_PID
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
rm --force Archive.tar.gz
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

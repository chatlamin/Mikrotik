/caps-man channel
add band=2ghz-b/g/n name=2.4-channel-auto
add band=5ghz-a/n/ac name=5-channel-auto
/caps-man datapath
add bridge=bridge-local client-to-client-forwarding=yes local-forwarding=yes name=datapath
/caps-man security
add authentication-types=wpa-psk,wpa2-psk encryption=aes-ccm group-encryption=aes-ccm name=security passphrase=123456789
/caps-man configuration
add channel=2.4-channel-auto datapath=datapath name=cfg-2ghz security=security ssid=WiFi2.4
add channel=5-channel-auto datapath=datapath name=cfg-5ghz security=security ssid=WiFi5
/caps-man manager
set enabled=yes
/caps-man provisioning
add action=create-dynamic-enabled hw-supported-modes=b,gn master-configuration=cfg-2ghz name-format=prefix-identity name-prefix=2ghz
add action=create-dynamic-enabled hw-supported-modes=an,ac master-configuration=cfg-5ghz name-format=prefix-identity name-prefix=5ghz

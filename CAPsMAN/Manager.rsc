# Interfaces
/interface ethernet
    set [ find default-name=ether1 ] name=ether1-gateway
/interface bridge
    add name=bridge-local protocol-mode=none
/interface bridge port
    add bridge=bridge-local interface=ether2
    add bridge=bridge-local interface=ether3
    add bridge=bridge-local interface=ether4
    add bridge=bridge-local interface=ether5

# Firewall
/ip firewall filter
    add action=drop chain=input comment="Block DNS requests from outer world" dst-port=53 in-interface=ether1-gateway protocol=udp
    add action=drop chain=input comment="Block DNS requests from outer world" dst-port=53 in-interface=ether1-gateway protocol=tcp
    add action=drop chain=forward comment="Block SMTP overuse" dst-port=25 protocol=tcp src-address-list=smtp-overuse
    add action=drop chain=forward comment="Block SMB" dst-port=139,445 log=yes out-interface=ether1-gateway protocol=tcp
    add action=drop chain=input comment="Port scan: Drop port scanners" in-interface=ether1-gateway src-address-list=port-scan
    add action=add-src-to-address-list address-list=port-scan address-list-timeout=2w chain=input comment="Port scan: PSD" in-interface=ether1-gateway protocol=tcp psd=21,3s,3,1
    add action=add-src-to-address-list address-list=port-scan address-list-timeout=2w chain=input comment="Port scan: NMAP FIN Stealth scan" in-interface=ether1-gateway protocol=tcp tcp-flags=fin,!syn,!rst,!psh,!ack,!urg
    add action=add-src-to-address-list address-list=port-scan address-list-timeout=2w chain=input comment="Port scan: SYN/FIN scan" in-interface=ether1-gateway protocol=tcp tcp-flags=fin,syn
    add action=add-src-to-address-list address-list=port-scan address-list-timeout=2w chain=input comment="Port scan: SYN/RST scan" in-interface=ether1-gateway protocol=tcp tcp-flags=syn,rst
    add action=add-src-to-address-list address-list=port-scan address-list-timeout=2w chain=input comment="Port scan: FIN/PSH/URG scan" in-interface=ether1-gateway protocol=tcp tcp-flags=fin,psh,urg,!syn,!rst,!ack
    add action=add-src-to-address-list address-list=port-scan address-list-timeout=2w chain=input comment="Port scan: ALL/ALL scan" in-interface=ether1-gateway protocol=tcp tcp-flags=fin,syn,rst,psh,ack,urg
    add action=add-src-to-address-list address-list=port-scan address-list-timeout=2w chain=input comment="Port scan: NMAP NULL scan" in-interface=ether1-gateway protocol=tcp tcp-flags=!fin,!syn,!rst,!psh,!ack,!urg

# Addresses
/ip address
    add address=192.168.88.1/24 interface=bridge-local

# Logging
/system logging action
    set [ find name=memory ] memory-lines=1000

# Services
/ip service
    set api disabled=yes
    set api-ssl disabled=yes
    set ftp disabled=yes
    set ssh address=192.168.88.0/24
    set telnet disabled=yes
    set winbox address=192.168.88.0/24
    set www disabled=yes
    set www-ssl disabled=yes

# Date-time
/system clock
    set time-zone-name=Europe/Moscow
/system ntp client
    set enabled=yes primary-ntp=[ :resolve ru.pool.ntp.org ] secondary-ntp=[ :resolve de.pool.ntp.org ]

# Scheduler
/system scheduler
    add interval=1d name=refresh-ntp-servers on-event="/system ntp client set primary-ntp=[ :resolve ru.pool.ntp.org ] secondary-ntp=[ :resolve de.pool.ntp.org ]\r\
    \n:log warn \"NTP servers refreshed\"" start-date=jan/01/1970 start-time=01:00:00
/system scheduler
    add interval=2h name=log-smtp-overuse on-event=":local count [ :len [ /ip firewall address-list find list=smtp-overuse disabled=no ] ];\r\
    \n:if ( \$count > 0 ) do={\r\
    \n  :log warning \"SMTP overuse: \$[ \$count ] host(s) detected\";\r\
    \n}" start-date=jan/01/1970 start-time=01:00:00

# DNS
/ip dns
    set allow-remote-requests=yes cache-max-ttl=1d

# NAT
/ip firewall nat
    add action=masquerade chain=srcnat src-address=192.168.88.0/24

# Identity
/system identity
    set name=capsman

# List
/interface list
    add name=local-interface
/interface list member
    add interface=bridge-local list=local-interface

# MAC Server
/tool mac-server
    set allowed-interface-list=local-interface
/tool mac-server mac-winbox
    set allowed-interface-list=local-interface

# Neighbor
/ip neighbor discovery-settings
    set discover-interface-list=local-interface

# Pool
/ip pool
    add name=pool-local ranges=192.168.88.10-192.168.88.254

# DHCP Server
/ip dhcp-server
    add address-pool=pool-local authoritative=after-2sec-delay disabled=no \
    interface=bridge-local lease-time=7d name=dhcp-local
/ip dhcp-server network
    add address=192.168.88.0/24 dns-server=192.168.88.1 gateway=192.168.88.1 \
    netmask=24

# DHCP Client
/ip dhcp-client
    add interface=ether1-gateway disabled=no

# CAPsMAN
/caps-man channel
    add band=2ghz-b/g/n name=2.4-channel-auto
    add band=5ghz-a/n/ac name=5-channel-auto
/caps-man datapath
    add bridge=bridge-local client-to-client-forwarding=yes local-forwarding=yes name=datapath
/caps-man security
    add authentication-types=wpa-psk,wpa2-psk encryption=aes-ccm group-encryption=aes-ccm name=security passphrase=1234567890
/caps-man configuration
    add channel=2.4-channel-auto datapath=datapath name=cfg-2ghz security=security ssid=WiFi2.4
    add channel=5-channel-auto datapath=datapath name=cfg-5ghz security=security ssid=WiFi5
/caps-man manager
    set enabled=yes
/caps-man provisioning
    add action=create-dynamic-enabled hw-supported-modes=b,gn master-configuration=cfg-2ghz name-format=prefix-identity name-prefix=2ghz
    add action=create-dynamic-enabled hw-supported-modes=an,ac master-configuration=cfg-5ghz name-format=prefix-identity name-prefix=5ghz


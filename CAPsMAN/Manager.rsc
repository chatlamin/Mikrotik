# Reset config
/system reset-configuration no-defaults=yes


# Interfaces
/interface ethernet
    set [ find default-name=ether1 ] name=ether1-gateway
/interface bridge
    add name=bridge-free-wifi protocol-mode=none
    add name=bridge-office-eth protocol-mode=none
    add name=bridge-office-wifi protocol-mode=none
    add name=bridgeCAP protocol-mode=none
/interface bridge port
    add bridge=bridge-office-eth interface=ether2
    add bridge=bridge-office-eth interface=ether3
    add bridge=bridge-office-eth interface=ether4
    add bridge=bridge-office-eth interface=ether5

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
    add address=192.168.101.1/24 comment=free-wifi interface=bridge-free-wifi network=192.168.101.0
    add address=192.168.99.1/24 comment=office-wifi interface=bridge-office-wifi network=192.168.99.0
    add address=192.168.100.1/24 comment=office-eth interface=bridge-office-eth network=192.168.100.0

# DHCP Client
/ip dhcp-client
    add interface=ether1-gateway disabled=no

# Logging
/system logging action
    set [ find name=memory ] memory-lines=1000

# Services
/ip service
    set api disabled=yes
    set api-ssl disabled=yes
    set ftp disabled=yes
    set ssh address=192.168.100.0/24
    set telnet disabled=yes
    set winbox address=192.168.100.0/24
    set www disabled=yes
    set www-ssl disabled=yes

# Date-time
/delay 5
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
    add action=masquerade chain=srcnat src-address=192.168.100.0/24
    add action=masquerade chain=srcnat src-address=192.168.101.0/24
    add action=masquerade chain=srcnat src-address=192.168.99.0/24

# Identity
/system identity
    set name=Manager

# List
/interface list
    add name=local-interface
/interface list member
    add interface=bridge-office-eth list=local-interface

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
    add name=free-wifi ranges=192.168.101.2-192.168.101.254
    add name=office-eth ranges=192.168.100.10-192.168.100.254
    add name=office-wifi ranges=192.168.99.2-192.168.99.254

# DHCP Server
/ip dhcp-server
    add address-pool=office-eth authoritative=after-2sec-delay disabled=no interface=bridge-office-eth lease-time=1d name=dhcp-office-eth
    add address-pool=free-wifi authoritative=after-2sec-delay disabled=no interface=bridge-free-wifi lease-time=1h name=dhcp-free-wifi
    add address-pool=office-wifi authoritative=after-2sec-delay disabled=no interface=bridge-office-wifi lease-time=1h name=dhcp-office-wifi

/ip dhcp-server network
    add address=192.168.99.0/24 dns-server=192.168.99.1 gateway=192.168.99.1
    add address=192.168.100.0/24 dns-server=192.168.100.1 gateway=192.168.100.1
    add address=192.168.101.0/24 dns-server=192.168.101.1 gateway=192.168.101.1

# CAPsMAN
/caps-man channel
    add band=2ghz-b/g/n name=channel-auto-2.4
    add band=5ghz-a/n/ac name=channel-auto-5
/caps-man datapath
    add bridge=bridge-office-wifi client-to-client-forwarding=yes name=datapath-office
    add bridge=bridge-free-wifi client-to-client-forwarding=yes name=datapath-free
/caps-man security
    add authentication-types=wpa-psk,wpa2-psk encryption=aes-ccm group-encryption=aes-ccm name=security-free passphrase=1234qwer
    add authentication-types=wpa-psk,wpa2-psk encryption=aes-ccm group-encryption=aes-ccm name=security-office passphrase=12345qwert
/caps-man configuration
    add channel=channel-auto-2.4 datapath=datapath-free name=cfg-2.4-free security=security-free ssid=free-wifi-2.4
    add channel=channel-auto-2.4 datapath=datapath-office name=cfg-2.4-office security=security-office ssid=office-wifi-2.4
    add channel=channel-auto-5 datapath=datapath-free name=cfg-5-free security=security-free ssid=free-wifi-5
    add channel=channel-auto-5 datapath=datapath-office name=cfg-5-office security=security-office ssid=office-wifi-5
/caps-man manager
    set enabled=yes
/caps-man provisioning
    add action=create-dynamic-enabled hw-supported-modes=b,gn master-configuration=cfg-2.4-office name-format=prefix-identity name-prefix=2.4 slave-configurations=cfg-2.4-free
    add action=create-dynamic-enabled hw-supported-modes=a,ac,an master-configuration=cfg-5-office name-format=prefix-identity name-prefix=5 slave-configurations=cfg-5-free

# CAP
/interface wireless cap
    set discovery-interfaces=bridgeCAP enabled=yes interfaces=wlan1,wlan2

# Backup
#------------------------------------------------------------
/system backup save
#------------------------------------------------------------


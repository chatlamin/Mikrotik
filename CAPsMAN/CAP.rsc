# Reset config
/system reset-configuration no-defaults=yes

/interface bridge
    add name=bridge-local protocol-mode=none
/interface bridge port
    add bridge=bridge-local interface=ether1
    add bridge=bridge-local interface=ether2
    add bridge=bridge-local interface=ether3
    add bridge=bridge-local interface=ether4
    add bridge=bridge-local interface=ether5
/ip address
    add address=192.168.100.2/24 interface=bridge-local network=192.168.100.0
/ip route
    add distance=1 gateway=192.168.100.1
/ip dns
    set servers=192.168.100.1
/ip service
    set telnet disabled=yes
    set ftp disabled=yes
    set www disabled=yes
    set ssh disabled=yes
    set api disabled=yes
    set winbox address=192.168.100.0/24
    set api-ssl disabled=yes
/interface wireless cap
    set bridge=bridge-local caps-man-addresses=192.168.100.1 enabled=yes interfaces=wlan1,wlan2
/




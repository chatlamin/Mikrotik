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

/system clock
    set time-zone-name=Europe/Moscow
/system ntp client
    set enabled=yes primary-ntp=[ :resolve ru.pool.ntp.org ] secondary-ntp=[ :resolve de.pool.ntp.org ]

/system scheduler
    add interval=1d name=refresh-ntp-servers on-event="/system ntp client set primary-ntp=[ :resolve ru.pool.ntp.org ] secondary-ntp=[ :resolve de.pool.ntp.org ]\r\
    \n:log warn \"NTP servers refreshed\"" start-date=jan/01/1970 start-time=01:00:00
/system scheduler
    add interval=2h name=log-smtp-overuse on-event=":local count [ :len [ /ip firewall address-list find list=smtp-overuse disabled=no ] ];\r\
    \n:if ( \$count > 0 ) do={\r\
    \n  :log warning \"SMTP overuse: \$[ \$count ] host(s) detected\";\r\
    \n}" start-date=jan/01/1970 start-time=01:00:00

/system logging action
    set [ find name=memory ] memory-lines=1000

/system package update download

/execute "/system reboot"

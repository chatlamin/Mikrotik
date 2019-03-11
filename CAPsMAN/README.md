### Краткое описание настроек

#### Manager
Ether1 настраивается как WAN port с типом подключения dhcp-client. ether2-ether5 объединяются в bridge (подразумевается, что это будет локальная сеть) ip на brigde 192.168.88.1, dhcp-server на bridge с pool 192.168.88.10-192.168.88.254. Services доступны только из локальной сети. CAPsMAN настраивается на работу с микротикам, отдавая им настройки с SSID отдельно, для 2.4 и 5 ghz. client-to-client-forwarding и local-forwarding включены, интерфейсы точек динамически добавляются в bridge.

#### CAP
Ether1-Ether5 объеденены в bridge, ip на bridge 192.168.88.2. микротик запрашивает настройки WiFi с 192.168.88.1 для wlan1 и wlan2.

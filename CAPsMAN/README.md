# CAPsMAN с двумя SSID — гостевая и рабочая сеть

## CAP = CAPSMAN (identity "Manager")

Центральный маршрутизатор будет выполнять роль CAPsMAN и роль CAP.

Ether1 настраивается как WAN port с типом подключения dhcp-client. ether2-ether5 объединяются в bridge-office-eth (подразумевается, что это будет служебная локальная сеть).

Ip -> Services доступны только из bridge-office-eth.

CAPsMAN отдаёт настройки с SSID отдельно, для 2.4 и 5 ghz. Включен client-to-client-forwarding для передачи данных от клиета к клиенту. bridge-office-wifi для служебной wifi сети. bridge-free-wifi для гостевой wifi сети. CAP на CAPsMAN настроен discovery-interfaces=bridgeCAP

На каждый бридж делаем отдельный dhcp сервер с своим пулом адресов.

## CAP (identity "CAP")

Ether1-Ether5 объеденены в bridge, ip на bridge 192.168.88.2. микротик запрашивает настройки WiFi с 192.168.88.1 для wlan1 и wlan2.

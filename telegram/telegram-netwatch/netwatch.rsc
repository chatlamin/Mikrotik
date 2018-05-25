/tool netwatch
add down-script="/log warning \"telegram: Host DOWN\"\r\
    \n\r\
    \n:local botAPI \"YOUR_BOT_API\"\r\
    \n:local chatID \"YOUR_CHAT_ID\"\r\
    \n:local message \"Host DOWN\"\r\
    \n\r\
    \n/tool fetch url=\"https://api.telegram.org/bot\$botAPI/sendMessage\\\?chat_id=\$chatID&text=\$message\" keep-result=no" host=192.168.88.5 interval=30s up-script="/log warning \"telegram: Host UP\"\r\
    \n\r\
    \n:local botAPI \"YOUR_BOT_API\"\r\
    \n:local chatID \"YOUR_CHAT_ID\"\r\
    \n:local message \"Host UP\"\r\
    \n\r\
    \n/tool fetch url=\"https://api.telegram.org/bot\$botAPI/sendMessage\\\?chat_id=\$chatID&text=\$message\" keep-result=no"

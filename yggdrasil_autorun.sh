#!/bin/bash

echo "Запуск Yggdrasil одним кликом для ленивых линукс юзеров :) by Akamirsky..."
echo "---"
echo "Для корректной работы без запроса пароля читаем Readme"

# Команды выполняются через sudo без запроса пароля благодаря настройкам sudoers
sudo systemctl start yggdrasil.service
sudo yggdrasilctl getself

echo "---"
echo "Готово, чекай подключение!"

# Обратный отсчет
SECONDS_TO_WAIT=5
# Печатаем начальный текст
echo -ne "Окно закроется через $SECONDS_TO_WAIT секунд... "

for i in $(seq $SECONDS_TO_WAIT -1 1); do
    echo -ne "$i \b\b"
    sleep 1
done

echo -e "0  \b\b\n"

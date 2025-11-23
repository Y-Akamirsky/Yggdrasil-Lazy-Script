#!/bin/bash

# --- Настройки ---
TARGET_NAME="yggdrasil-launcher"
TARGET_PATH="/usr/local/bin/$TARGET_NAME"
SUDOERS_FILE="/etc/sudoers.d/yggdrasil_lazy"
DESKTOP_FILE_PATH="$HOME/.local/share/applications/Yggdrasil-Lazy.desktop"
CURRENT_USER=$(whoami)

echo "--- Установщик Yggdrasil Lazy Launcher ---"
echo "Скрипт будет установлен в $TARGET_PATH"

# Запрашиваем права sudo сразу
if ! sudo -v; then
    echo "Отмена операции или неверный пароль."
    exit 1
fi

# --- 1. Создание скрипта запуска (ГЕНЕРАЦИЯ НА ЛЕТУ) ---
echo "Генерация и установка исполняемого файла..."

# ВНИМАНИЕ: Вставь код из твоего yggdrasil_autorun.sh между EOF ниже.
# Используем 'EOF' в кавычках, чтобы переменные внутри не раскрывались при установке.

sudo tee "$TARGET_PATH" > /dev/null << 'EOF'
#!/bin/bash
# --- НАЧАЛО ВСТРОЕННОГО СКРИПТА ---

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

# --- КОНЕЦ ВСТРОЕННОГО СКРИПТА ---
EOF

# --- Настройка прав ---
sudo chown root:root "$TARGET_PATH"
sudo chmod 755 "$TARGET_PATH"

echo "Файл создан и защищен."

# --- 2. Настройка sudoers ---
echo "Настройка запуска без пароля..."
SUDO_RULE="$CURRENT_USER ALL=(ALL) NOPASSWD: $TARGET_PATH"

echo "$SUDO_RULE" | sudo tee "$SUDOERS_FILE" > /dev/null
sudo chmod 440 "$SUDOERS_FILE"

# --- 3. Создание ярлыка ---
echo "Создание ярлыка..."

mkdir -p "$HOME/.local/share/applications"

cat <<EOF > "$DESKTOP_FILE_PATH"
[Desktop Entry]
Name=Yggdrasil Lazy
Comment=Start Yggdrasil service manually
Exec=sudo $TARGET_NAME
Terminal=true
Type=Application
Categories=Network;System;
Icon=utilities-terminal
StartupNotify=true
EOF

chmod +x "$DESKTOP_FILE_PATH"
update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null

echo "---"
echo "Установка завершена! Можно запускать через меню приложений."

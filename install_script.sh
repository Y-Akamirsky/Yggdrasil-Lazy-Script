#!/bin/bash

# --- Настройки ---
TARGET_NAME="yggdrasil-launcher"
TARGET_PATH="/usr/local/bin/$TARGET_NAME"
SUDOERS_FILE="/etc/sudoers.d/yggdrasil_lazy"
DESKTOP_FILE_PATH="$HOME/.local/share/applications/Yggdrasil-Lazy.desktop"
CURRENT_USER=$(whoami)

# --- Настройки иконки ---
ICON_URL="https://raw.githubusercontent.com/Y-Akamirsky/Yggdrasil-Lazy-Script/refs/heads/main/yggdrasil.svg"
ICON_NAME="yggdrasil-lazy"
# МЕНЯЕМ ПУТЬ: Устанавливаем иконку в локальную папку пользователя (не требуя sudo)
ICON_TARGET_DIR="$HOME/.local/share/icons/hicolor/scalable/apps"
FULL_ICON_PATH="$ICON_TARGET_DIR/$ICON_NAME.svg"

echo "--- Установщик Yggdrasil Lazy Launcher ---"
echo "Скрипт будет установлен в $TARGET_PATH"

# Запрашиваем права sudo сразу
if ! sudo -v; then
    echo "Отмена операции или неверный пароль."
    exit 1
fi

# --- 1. Создание скрипта запуска (ГЕНЕРАЦИЯ НА ЛЕТУ) ---
echo "Генерация и установка исполняемого файла..."

# ВНИМАНИЕ: Код встроенного скрипта остается без изменений
sudo tee "$TARGET_PATH" > /dev/null << 'EOF'
#!/bin/bash
# --- НАЧАЛО ВСТРОЕННОГО СКРИПТА ---

echo "Запуск Yggdrasil одним кликом для ленивых линукс юзеров :) by Akamirsky..."
echo "---"
echo "Запуск демона yggdrasil.service"

sleep 1

sudo systemctl start yggdrasil.service

echo "Проверка подключения через 2 секунды"

sleep 2

sudo yggdrasilctl getself

echo "---"
echo "Готово. Если не уверен, проверь подключение сам"
echo "выполнив команду sudo yggdrasilctl getself вручную"
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

# --- 2. Настройка прав (Скрипт) ---
sudo chown root:root "$TARGET_PATH"
sudo chmod 755 "$TARGET_PATH"

echo "Файл создан и защищен."

# --- 3. Настройка sudoers ---
echo "Настройка запуска без пароля..."
SUDO_RULE="$CURRENT_USER ALL=(ALL) NOPASSWD: $TARGET_PATH"

echo "$SUDO_RULE" | sudo tee "$SUDOERS_FILE" > /dev/null
sudo chmod 440 "$SUDOERS_FILE"

# --- 4. Установка иконки (БЕЗ SUDO) ---
echo "Скачивание и установка иконки в локальный каталог..."

# Создаем папку без sudo, т.к. она в $HOME
mkdir -p "$ICON_TARGET_DIR"

# Скачиваем иконку без sudo
if ! curl -L "$ICON_URL" -o "$FULL_ICON_PATH"; then
    echo "ПРЕДУПРЕЖДЕНИЕ: Не удалось скачать иконку."
else
    # Обновляем кэш иконок (без sudo, т.к. каталог локальный)
    gtk-update-icon-cache -f "$ICON_TARGET_DIR" 2>/dev/null
    echo "Иконка установлена локально."
fi

# --- 5. Создание ярлыка ---
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
Icon=$FULL_ICON_PATH
StartupNotify=true
EOF

# Now with Icon!

chmod +x "$DESKTOP_FILE_PATH"
update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null

echo "---"
echo "Установка завершена! Можно запускать через меню приложений."

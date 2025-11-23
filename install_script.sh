#!/bin/bash

INSTALL_DIR="$HOME/.local/share/yggdrasil"
SCRIPT_NAME="yggdrasil_autorun.sh"
FULL_SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"
CURRENT_USER=$(whoami)
DESKTOP_FILE_NAME="Yggdrasil-Lazy.desktop"
DESKTOP_FILE_PATH="$HOME/.local/share/applications/$DESKTOP_FILE_NAME"

echo "Начало установки. Сейчас потребуется ввести ваш пароль администратора (sudo)."
sudo -v

if [ $? -ne 0 ]; then
    echo "Неверный пароль или отмена. Установка прервана."
    exit 1
fi

# --- Установка основного скрипта и sudoers ---

mkdir -p "$INSTALL_DIR"
cp "./$SCRIPT_NAME" "$FULL_SCRIPT_PATH"
chmod +x "$FULL_SCRIPT_PATH"

SUDO_RULE="$CURRENT_USER ALL=(ALL) NOPASSWD: $FULL_SCRIPT_PATH"
if sudo grep -qF "$SUDO_RULE" /etc/sudoers /etc/sudoers.d/*; then
    echo "Правило sudoers уже существует."
else
    echo "Добавляю правило NOPASSWD в /etc/sudoers."
    sudo sed -i "\$a$SUDO_RULE" /etc/sudoers
fi

# --- Автоматическое создание и установка .desktop файла ---

echo "Создание файла ярлыка скрипта..."

# Создаем содержимое .desktop файла, используя динамический путь $FULL_SCRIPT_PATH
cat <<EOF > "$DESKTOP_FILE_PATH"
[Desktop Entry]
Name=Yggdrasil Lazy
Comment=Start Yggdrasil service and check connection
Exec=$FULL_SCRIPT_PATH
Terminal=true
Type=Application
Categories=System;Tools;
Icon=utilities-terminal
StartupNotify=true
EOF

# Делаем файл ярлыка исполняемым
chmod +x "$DESKTOP_FILE_PATH"

# Обновляем базу данных меню приложений (для некоторых DE Linux это нужно)
update-desktop-database ~/.local/share/applications/ 2>/dev/null

echo "---"
echo "Установка завершена."
echo "Ярлык 'Yggdrasil Lazy' добавлен в ваше меню приложений."

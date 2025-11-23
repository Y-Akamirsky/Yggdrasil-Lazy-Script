#!/bin/bash

# --- Настройки ---
# Определяем, где лежит этот установщик
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SOURCE_SCRIPT="yggdrasil_autorun.sh"

# Новое место установки: системная папка для пользовательских программ
TARGET_NAME="yggdrasil-launcher"
TARGET_PATH="/usr/local/bin/$TARGET_NAME"

# Файл правил sudo
SUDOERS_FILE="/etc/sudoers.d/yggdrasil_lazy"

# Путь к ярлыку (остается в папке пользователя)
DESKTOP_FILE_PATH="$HOME/.local/share/applications/Yggdrasil-Lazy.desktop"
CURRENT_USER=$(whoami)

echo "--- Установщик Yggdrasil Lazy Launcher ---"
echo "Скрипт будет установлен в $TARGET_PATH"
echo "Это потребует ввода пароля администратора (sudo) для настройки прав."

# Проверка наличия исходного файла
if [ ! -f "$SCRIPT_DIR/$SOURCE_SCRIPT" ]; then
    echo "ОШИБКА: Файл $SOURCE_SCRIPT не найден в папке $SCRIPT_DIR"
    exit 1
fi

# Запрашиваем права sudo сразу
if ! sudo -v; then
    echo "Отмена операции или неверный пароль."
    exit 1
fi

# --- 1. Установка скрипта в систему ---
echo "Установка исполняемого файла..."

# Копируем файл
sudo cp "$SCRIPT_DIR/$SOURCE_SCRIPT" "$TARGET_PATH"

# ВАЖНО: Делаем владельцем root (чтобы никто не мог подменить код)
sudo chown root:root "$TARGET_PATH"
# Даем права: rwxr-xr-x (владелец: всё, остальные: только чтение и запуск)
sudo chmod 755 "$TARGET_PATH"

echo "Файл установлен и защищен от изменений."

# --- 2. Настройка sudoers ---
echo "Настройка запуска без пароля..."

# Правило: Пользователь может запускать ТОЛЬКО ЭТОТ файл без пароля
SUDO_RULE="$CURRENT_USER ALL=(ALL) NOPASSWD: $TARGET_PATH"

# Записываем безопасно через временный вывод
echo "$SUDO_RULE" | sudo tee "$SUDOERS_FILE" > /dev/null
sudo chmod 440 "$SUDOERS_FILE" # Обязательные права для файлов sudoers

echo "Правило добавлено в $SUDOERS_FILE"

# --- 3. Создание ярлыка ---
echo "Создание ярлыка в меню приложений..."

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
echo "Установка успешно завершена!"
echo "Теперь вы можете запускать Yggdrasil через меню приложений."

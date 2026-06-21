#!/bin/bash

if [ "$1" == "--help" ]; then
    echo "Справка по скрипту:"
    echo "Запуск: $0 [--debug] <папка> <шаблон> [количество]"
    echo "Пример: $0 folder testfile 5"
    exit 0
fi

DEBUG="false"
if [ "$1" == "--debug" ]; then
    DEBUG="true"
    shift 
fi


debug_log() {
    if [ "$DEBUG" == "true" ]; then
        echo "[DEBUG] $1"
    fi
}

DIR="$1"
TEMPLATE="$2"
COUNT="$3"


if [ -z "$DIR" ] || [ -z "$TEMPLATE" ]; then
    echo "Ошибка: Вы не ввели папку или шаблон."
    echo "Введите $0 --help для справки."
    exit 1
fi


if [[ "$DIR" == -* ]] || [[ "$TEMPLATE" == -* ]]; then
    echo "Ошибка: Имя папки или шаблона не может начинаться с дефиса (-)."
    echo "Возможно,  опечатка фо флаге (ввели '-- help' вместо '--help')."
    exit 1
fi


if [ -z "$COUNT" ]; then
    COUNT=10
fi

debug_log "Настройки: Папка=$DIR, Шаблон=$TEMPLATE, Кол-во=$COUNT"

if [ -d "$DIR" ]; then
    echo "Внимание! Папка '$DIR' уже существует."
    echo "1) Удалить содержимое"
    echo "2) Архивировать содержимое"
    read -p "Выберите цифру (1 или 2): " choice

    if [ "$choice" == "1" ]; then
        read -p "Удалить все сразу (all) или с подтверждением (one)? [all/one]: " del_choice
        if [ "$del_choice" == "all" ]; then
            debug_log "Удаляем все файлы в папке $DIR..."
            rm -f "$DIR"/*
        else
            debug_log "Ручное удаление..."
            rm -i "$DIR"/*
        fi
    elif [ "$choice" == "2" ]; then
        read -p "Введите имя для архива: " arc_name
        NOW=$(date +"%Y%m%d%H%M_%S")
        ARC_DIR="archives"

        debug_log "Создаем папку $ARC_DIR"
        mkdir -p "$ARC_DIR"

        FULL_ARC_NAME="$ARC_DIR/${arc_name}_${NOW}.tar.gz"
        debug_log "Создаем архив $FULL_ARC_NAME"
        
        
        tar -czf "$FULL_ARC_NAME" -C "$DIR" .

        debug_log "Очищаем папку $DIR после архивации"
        rm -f "$DIR"/*
        echo "Файлы заархивированы!"
    else
        echo "Неправильный выбор."
        exit 1
    fi
else
    debug_log "Папки нет, создаем : $DIR"
    mkdir -p "$DIR"
fi

echo "Создаем $COUNT файлов..."

for i in $(seq 1 "$COUNT"); do
    NUM=$(printf "%03d" "$i")
    FILENAME="${TEMPLATE}_${NUM}.txt"
    FILEPATH="$DIR/$FILENAME"

    debug_log "Генерируем файл $FILENAME"

    > "$FILEPATH"

    RAND_LEN=$(( RANDOM % 91 + 10 ))

    CURRENT_LEN=0
    while [ "$CURRENT_LEN" -lt "$RAND_LEN" ]; do
        CHUNK=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | head -c 10)
        echo "$CHUNK" >> "$FILEPATH"
        CURRENT_LEN=$((CURRENT_LEN + 10))
    done
done

echo "Файлы созданы!"

debug_log "Подсчет строк в файлах..."
TOTAL_FILES=0
MIN_LINES=999999
MAX_LINES=0

for file in "$DIR"/*; do
    if [ -f "$file" ]; then
        TOTAL_FILES=$((TOTAL_FILES + 1))
        LINES=$(wc -l < "$file")

        if [ "$LINES" -lt "$MIN_LINES" ]; then
            MIN_LINES="$LINES"
        fi

        if [ "$LINES" -gt "$MAX_LINES" ]; then
            MAX_LINES="$LINES"
        fi
    fi
done

if [ "$TOTAL_FILES" -eq 0 ]; then
    MIN_LINES=0
fi

echo ""
echo "=== СТАТИСТИКА ==="
echo "Всего файлов: $TOTAL_FILES"
echo "Мин. число строк: $MIN_LINES"
echo "Макс. число строк: $MAX_LINES"
echo "=================="
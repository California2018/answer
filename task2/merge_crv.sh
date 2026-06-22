#!/bin/bash

OUTPUT_FILE="final_result.csv"
rm -f "$OUTPUT_FILE"
shopt -s nullglob
FILES=(*.csv)


if [ ${#FILES[@]} -eq 0 ]; then
    echo "Ошибка: В текущей директории нет файлов формата .csv"
    exit 1
fi

echo "Найдено файлов для слияния: ${#FILES[@]}"
head -n 1 "${FILES[0]}" > "$OUTPUT_FILE"


for file in "${FILES[@]}"; do
    tail -n +2 "$file" >> "$OUTPUT_FILE"
done

echo "Данные успешно собраны в файл: $OUTPUT_FILE"
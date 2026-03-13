#!/bin/bash
# GitHub Push Script for fangtest repository
# Usage: bash push.sh YOUR_GITHUB_TOKEN

if [ $# -eq 0 ]; then
    echo "❌ Ошибка: не указан GitHub token"
    echo ""
    echo "Использование:"
    echo "  bash push.sh ghp_xxxxxxxxxxxx"
    echo ""
    echo "Как получить токен:"
    echo "  1. Откройте https://github.com/settings/tokens"
    echo "  2. Нажмите 'Generate new token (classic)'"
    echo "  3. Выберите scope: repo"
    echo "  4. Сгенерируйте и скопируйте токен"
    exit 1
fi

TOKEN="$1"
REPO_URL="https://spencer888:${TOKEN}@github.com/spencer888/fangtest.git"

cd ~/.openfang

echo "🚀 Пушим репозиторий на GitHub..."
echo "   URL: https://github.com/spencer888/fangtest"
echo ""

# Настраиваем remote с токеном
git remote set-url origin "$REPO_URL"

# Пушим
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ УСПЕХ!"
    echo ""
    echo "📁 Репозиторий запушен на:"
    echo "   https://github.com/spencer888/fangtest"
    echo ""
    echo "📊 Статистика:"
    echo "   $(git rev-list --count HEAD) коммитов"
    echo "   $(git ls-files | wc -l) файлов"
    echo ""
    echo "🧹 Очищаем токен из remote..."
    git remote set-url origin https://github.com/spencer888/fangtest.git
    echo "✅ Готово!"
else
    echo ""
    echo "❌ Ошибка пуша. Проверьте токен."
    git remote set-url origin https://github.com/spencer888/fangtest.git
    exit 1
fi

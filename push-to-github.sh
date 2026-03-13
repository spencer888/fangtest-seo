#!/bin/bash
# Push script for GitHub

if [ -z "$1" ]; then
    echo "Использование: bash push-to-github.sh 'ghp_ваш_токен_здесь'"
    echo ""
    echo "Как получить токен:"
    echo "1. Откройте https://github.com/settings/tokens"
    echo "2. Нажмите 'Generate new token (classic)'"
    echo "3. Выберите scope: repo"
    echo "4. Сгенерируйте и скопируйте токен"
    exit 1
fi

TOKEN="$1"

cd ~/.openfang

# Configure git credentials
git config credential.helper store

# Create credential file
mkdir -p ~/.git-credentials
echo "https://spencer888:${TOKEN}@github.com" > ~/.git-credentials
chmod 600 ~/.git-credentials

# Push
echo "🚀 Пушим на GitHub..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Успешно запушено на https://github.com/spencer888/fangtest"
    echo ""
    echo "🧹 Очищаем временные credentials..."
    rm -f ~/.git-credentials
    git config --unset credential.helper 2>/dev/null || true
    echo "✅ Готово!"
else
    echo ""
    echo "❌ Ошибка пуша. Проверьте токен."
    rm -f ~/.git-credentials
fi

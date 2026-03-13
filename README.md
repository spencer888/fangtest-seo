# OpenFang SEO Workflow — РезервуарыСтрой

Telegram-бот для автоматической генерации и публикации SEO-статей про резервуары РГС.

## 🚀 Быстрый старт

```bash
# Установка
chmod +x telegram-poller.sh

# Запуск
nohup bash telegram-poller.sh >> data/poller.log 2>&1 &
```

## 🤖 Команды бота

Напишите боту `@erkin_erkinerkin_bot`:
- `РГС-75` — создать статью про РГС-75
- `РГС-100` — создать статью про РГС-100
- `статус` — последние публикации
- `/help` — справка

## 📁 Структура

```
├── agents/                 # OpenFang агенты
│   ├── seo-specialist/     # Генерация SEO-контента
│   ├── researcher/         # Исследование данных
│   ├── wp-publisher/       # Публикация в WordPress
│   └── telegram-orchestrator/  # Telegram бот
├── workflows/              # OpenFang workflow
│   ├── rezervuary-content.json      # Генерация контента
│   ├── rezervuary-seo.json          # Полный workflow
│   └── rezervuary-seo-simple.json   # Упрощённый
├── skills/                 # OpenFang skills
│   ├── humanize-ai-text/   # Улучшение текста
│   ├── web-scraper/        # Парсинг сайтов
│   └── writing-style/      # Стиль написания
├── telegram-poller.sh      # Telegram бот (bash)
├── run_seo_workflow.sh     # Cron workflow
└── config.toml            # OpenFang конфиг
```

## ✨ Особенности

- **600-800 слов** — оптимально для SEO
- **FAQ-секция** — для featured snippets в Google
- **Humanize** — улучшение естественности текста
- **SEO шаблон** — `template-seo-article.php` в WordPress
- **Все модели** — РГС-10 до РГС-1000

## 🔧 Настройка

1. Скопируйте `.env.example` в `.env` и заполните:
   - `OPENROUTER_API_KEY`
   - `TELEGRAM_BOT_TOKEN`
   - `WORDPRESS_APP_PASSWORD`

2. Настройте WordPress:
   - Создайте категорию "Резервуары РГС"
   - Активируйте шаблон `template-seo-article.php`

3. Запустите OpenFang daemon:
   ```bash
   ~/.openfang/bin/openfang start
   ```

## 📊 Workflow

```
Telegram → telegram-poller.sh → OpenRouter API (Gemini)
                                    ↓
                         600-800 слов + FAQ
                                    ↓
                         Humanize + SEO оптимизация
                                    ↓
                         WordPress REST API
                                    ↓
                         template-seo-article.php
                                    ↓
                         Telegram уведомление
```

## 📝 Лицензия

MIT License

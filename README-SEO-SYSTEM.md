# OpenFang SEO System - Полная документация

## 🎯 Описание системы

Автоматизированная система SEO-контента на базе OpenFang Agent OS с интеграцией WordPress и уведомлениями в Telegram.

**Возможности:**
- 🔍 Автоматическое исследование ключевых слов
- 📊 Анализ конкурентов в реальном времени
- ✍️ Генерация SEO-оптимизированного контента (<500 символов)
- 📝 Публикация в WordPress через REST API
- 📱 Мгновенные уведомления в Telegram
- 🎨 Tailwind CSS для современного дизайна

---

## 🏗 Архитектура

```
┌─────────────────────────────────────────────────────┐
│  OpenFang Agent OS (http://127.0.0.1:4200)         │
│  ├── seo-specialist (orchestrator)                  │
│  │   ├── wp-publisher (WordPress REST API)          │
│  │   ├── researcher-hand (web research)             │
│  │   └── collector-hand (data collection)           │
└─────────────────────────────────────────────────────┘
                         ↓
                  REST API Integration
                         ↓
┌─────────────────────────────────────────────────────┐
│  WordPress (http://localhost)                       │
│  ├── Theme: twentytwentyfive-seo                    │
│  │   ├── Tailwind CSS (CDN)                        │
│  │   ├── Custom meta tags                          │
│  │   └── REST API endpoints                        │
│  └── Pages: /rezervuary-rgs/, ...                  │
└─────────────────────────────────────────────────────┘
                         ↓
                  Webhook Notification
                         ↓
┌─────────────────────────────────────────────────────┐
│  Telegram Bot (@erkin_erkinerkin_bot)              │
│  ├── Success notifications                         │
│  ├── Error alerts                                  │
│  └── Status updates                                │
└─────────────────────────────────────────────────────┘
```

---

## 🚀 Быстрый старт

### 1. Запуск OpenFang Daemon

```bash
# Проверить статус
~/.openfang/bin/openfang status

# Запустить daemon (если не запущен)
~/.openfang/bin/openfang start

# Открыть Dashboard
xdg-open http://127.0.0.1:4200/
```

### 2. Тестовый workflow

**Через Web Dashboard:**
1. Открыть http://127.0.0.1:4200/
2. Выбрать агента `seo-specialist`
3. Отправить сообщение: `"Напиши статью про резервуары РГС-25"`
4. Дождаться выполнения (~58 секунд)

**Ожидаемый результат:**
- ✅ Исследование 15-20 ключевых слов
- ✅ Анализ 3-5 конкурентов
- ✅ Генерация контента (H1 + текст <500 символов)
- ✅ Публикация в WordPress
- ✅ Уведомление в Telegram

### 3. Проверка результатов

**WordPress:**
```bash
# Список всех страниц
curl -s http://localhost/wp-json/wp/v2/pages | jq '.[] | {title: .title.rendered, link: .link}'

# Проверить конкретную страницу
xdg-open http://localhost/rezervuary-rgs/
```

**Telegram:**
- Бот: @erkin_erkinerkin_bot
- Уведомления приходят автоматически после публикации

---

## 📁 Структура файлов

### OpenFang Agents

```
~/.openfang/
├── config.toml                    # Основная конфигурация
├── .env                           # Переменные окружения (API ключи)
├── agents/
│   ├── wp-publisher/
│   │   ├── agent.toml             # Конфигурация агента
│   │   └── prompts/
│   │       └── wp-publisher.md    # Инструкции
│   ├── seo-specialist/
│   │   ├── agent.toml
│   │   └── prompts/
│   │       └── seo-specialist.md
│   └── telegram-notifier/         # (создаётся вручную при необходимости)
│       ├── agent.toml
│       └── prompts/
│           └── telegram-notifier.md
└── data/
    └── openfang.db                # База данных агентов
```

### WordPress Theme

```
/var/www/html/wp-content/themes/twentytwentyfive-seo/
├── style.css                      # Стили темы + Tailwind импорт
├── functions.php                  # Функции:
│   ├── Tailwind CSS CDN           # Подключение Tailwind
│   ├── Custom meta tags           # SEO мета-теги
│   ├── REST API endpoints         # Кастомные endpoints
│   └── Canonical URLs             # Канонические ссылки
└── screenshot.png                 # Скриншот темы (опционально)
```

---

## 🔧 Конфигурация

### 1. OpenFang Config (~/.openfang/config.toml)

```toml
api_listen = "127.0.0.1:4200"

[default_model]
provider = "openrouter"
model = "stepfun/step-3.5-flash:free"
api_key_env = "OPENROUTER_API_KEY"

[memory]
decay_rate = 0.05
```

### 2. Environment Variables (~/.openfang/.env)

```bash
# LLM API Keys
OPENROUTER_API_KEY=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

# WordPress Configuration
WORDPRESS_URL=http://localhost
WORDPRESS_USERNAME=seoadmin
WORDPRESS_APP_PASSWORD=0f678d0464d7c4ba8d42514daa691889

# Telegram Configuration
TELEGRAM_BOT_TOKEN=8591048587:AAElSAdCnxpHja3ujJpTQzp5HQBPw9BHVvw
TELEGRAM_CHAT_ID=283500912
```

### 3. WordPress Database

```sql
-- База данных: hotel_wp
-- Пользователь: hotel_wp_user / hotel_wp_pass123

-- Администратор OpenFang
INSERT INTO wp_users (user_login, user_pass, user_email) 
VALUES ('seoadmin', MD5('TestPass123!'), 'admin@testwp.local');

-- Application Password
INSERT INTO wp_usermeta (user_id, meta_key, meta_value)
VALUES (2, 'application_passwords', '...OpenFang Integration...');
```

---

## 📊 API Endpoints

### OpenFang API

**Base URL:** `http://127.0.0.1:4200/api`

**Endpoints:**
```
GET  /status              # Статус daemon
GET  /agents              # Список агентов
POST /agents/{id}/chat    # Чат с агентом
GET  /models              # Доступные модели
```

**Пример запроса:**
```bash
curl -X POST http://127.0.0.1:4200/api/agents/e7f4c9cf/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Напиши статью про РГС-25"}'
```

### WordPress REST API

**Base URL:** `http://localhost/wp-json/wp/v2`

**Endpoints:**
```
GET  /pages               # Список страниц
POST /pages               # Создать страницу
GET  /pages/{id}          # Получить страницу
POST /pages/{id}          # Обновить страницу
```

**Пример создания страницы:**
```bash
curl -X POST http://localhost/wp-json/wp/v2/pages \
  -u "seoadmin:0f678d0464d7c4ba8d42514daa691889" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Тестовая страница",
    "content": "<!-- wp:html --><p>Контент</p><!-- /wp:html -->",
    "status": "publish",
    "meta": {
      "custom_meta_title": "SEO Title",
      "custom_meta_description": "SEO Description"
    }
  }'
```

### Telegram Bot API

**Base URL:** `https://api.telegram.org/bot{TOKEN}`

**Endpoints:**
```
POST /sendMessage         # Отправить сообщение
POST /sendDocument        # Отправить файл
GET  /getUpdates          # Получить обновления
```

**Пример отправки уведомления:**
```bash
curl -X POST "https://api.telegram.org/bot8591048587:AAElSAdCnxpHja3ujJpTQzp5HQBPw9BHVvw/sendMessage" \
  -H "Content-Type: application/json" \
  -d '{
    "chat_id": "283500912",
    "text": "✅ *Статья опубликована!*\n🔗 URL: http://localhost/page/",
    "parse_mode": "Markdown"
  }'
```

---

## 🎨 Настройка контента

### Структура SEO-статьи

**Обязательные элементы:**
```html
<!-- wp:html -->
<div class="max-w-4xl mx-auto px-4 py-8">
  <!-- H1: 50-60 символов, включает главное ключевое слово -->
  <h1 class="text-3xl md:text-4xl font-bold text-gray-900 mb-6 leading-tight">
    Двустенные резервуары РГС для АЗС под ключ
  </h1>
  
  <!-- Основной контент: 2-3 абзаца, <500 символов -->
  <div class="prose prose-lg max-w-none">
    <p class="text-lg text-gray-700 leading-relaxed mb-4">
      [Абзац 1: описание, преимущества]
    </p>
    
    <p class="text-lg text-gray-700 leading-relaxed mb-4">
      [Абзац 2: характеристики, цены]
    </p>
    
    <!-- CTA блок -->
    <div class="mt-6 p-4 bg-blue-50 border-l-4 border-blue-500 rounded">
      <p class="text-blue-800 font-medium">
        Заказать расчёт стоимости: 8 (800) 250-63-35
      </p>
    </div>
  </div>
</div>
<!-- /wp:html -->
```

### Мета-теги

**Title (50-60 символов):**
```
Двустенные резервуары РГС для АЗС: цены, производство под ключ
```

**Description (150-160 символов):**
```
Производство двустенных резервуаров РГС для АЗС под ключ. Цены от производителя, 
объём 5-100 м³. Наземные и подземные резервуары по ГОСТ 31385-2016. Срок службы 30+ лет.
```

---

## 🔍 Workflow агента seo-specialist

### Полный цикл выполнения

```
1. Пользователь: "Напиши статью про резервуары РГС-25"
   ↓
2. [seo-specialist] Получает запрос
   ↓
3. [researcher-hand] Исследование ключевых слов
   • web_search: "резервуары РГС-25"
   • web_search: "цена РГС-25"
   • web_search: "производство резервуаров"
   → Результат: 15-20 ключевых слов с частотностью
   ↓
4. [collector-hand] Анализ конкурентов
   • web_fetch: pnsk.ru/articles/...
   • web_fetch: topaz-azs.ru/...
   → Результат: структура статей, заголовки, мета-теги
   ↓
5. [seo-specialist] Генерация контента
   • H1 + текст (290-500 символов)
   • Meta Title + Description
   → Результат: JSON с контентом
   ↓
6. [wp-publisher] Публикация в WordPress
   • POST /wp-json/wp/v2/pages
   • Установка мета-тегов
   → Результат: page_id, page_url
   ↓
7. [telegram-notifier] Уведомление
   • POST /sendMessage
   → Результат: message_id
   ↓
8. Пользователь получает:
   ✅ URL страницы
   ✅ Список ключевых слов
   ✅ Telegram уведомление
```

### Время выполнения: ~58 секунд

---

## 🛠 Устранение неполадок

### Проблема: OpenFang daemon не запускается

**Решение:**
```bash
# Проверить логи
tail -f ~/.openfang/data/openfang.log

# Перезапустить
pkill -9 openfang
~/.openfang/bin/openfang start

# Проверить порт
netstat -tuln | grep 4200
```

### Проблема: WordPress не отвечает

**Решение:**
```bash
# Проверить Apache
systemctl status apache2

# Проверить MySQL
systemctl status mariadb

# Проверить права
ls -la /var/www/html/wp-content/

# Тестовый запрос
curl -I http://localhost/
```

### Проблема: Telegram уведомления не приходят

**Решение:**
```bash
# Проверить бота
curl "https://api.telegram.org/bot8591048587:AAElSAdCnxpHja3ujJpTQzp5HQBPw9BHVvw/getMe"

# Проверить Chat ID
curl "https://api.telegram.org/bot8591048587:AAElSAdCnxpHja3ujJpTQzp5HQBPw9BHVvw/getUpdates"

# Тестовое сообщение
curl -X POST "https://api.telegram.org/bot8591048587:AAElSAdCnxpHja3ujJpTQzp5HQBPw9BHVvw/sendMessage" \
  -H "Content-Type: application/json" \
  -d '{"chat_id": "283500912", "text": "Test"}'
```

### Проблема: Агент не создаёт страницу

**Решение:**
```bash
# Проверить Application Password
mysql -u hotel_wp_user -photel_wp_pass123 hotel_wp -e "SELECT * FROM wp_usermeta WHERE user_id=2 AND meta_key='application_passwords'"

# Тестовый запрос к WordPress API
curl -X POST http://localhost/wp-json/wp/v2/pages \
  -u "seoadmin:0f678d0464d7c4ba8d42514daa691889" \
  -H "Content-Type: application/json" \
  -d '{"title": "Test", "content": "Test", "status": "draft"}'

# Проверить логи агента
# (В Dashboard выбрать агента → History)
```

---

## 📈 Метрики и мониторинг

### Ключевые метрики

```bash
# Количество созданных страниц
curl -s http://localhost/wp-json/wp/v2/pages | jq 'length'

# Количество агентов
curl -s http://127.0.0.1:4200/api/status | jq '.agent_count'

# Uptime OpenFang
curl -s http://127.0.0.1:4200/api/status | jq '.uptime_seconds'

# Использование токенов
# (В Dashboard → Settings → Usage)
```

### Логирование

**OpenFang логи:**
```bash
# Реальное время
tail -f ~/.openfang/data/openfang.log

# TUI логи
cat ~/.openfang/tui.log
```

**WordPress логи:**
```bash
# Apache error log
tail -f /var/log/apache2/error.log

# WordPress debug.log (если включён)
tail -f /var/www/html/wp-content/debug.log
```

---

## 🔐 Безопасность

### Рекомендации

1. **Изменить пароли по умолчанию:**
   ```sql
   -- WordPress admin
   UPDATE wp_users SET user_pass = MD5('NEW_STRONG_PASSWORD') WHERE user_login = 'seoadmin';
   
   -- Перегенерировать Application Password
   -- (в админке: Users → Profile → Application Passwords)
   ```

2. **Ограничить доступ к API:**
   ```php
   // В functions.php добавить
   add_filter('rest_authentication_errors', function($result) {
       if (!is_user_logged_in() && $_SERVER['REQUEST_METHOD'] !== 'GET') {
           return new WP_Error('rest_disabled', 'API limited', ['status' => 401]);
       }
       return $result;
   });
   ```

3. **HTTPS для продакшена:**
   ```bash
   # Установить Certbot
   sudo apt install certbot python3-certbot-apache
   sudo certbot --apache -d yourdomain.com
   ```

4. **Бэкапы:**
   ```bash
   # Бэкап БД
   mysqldump -u hotel_wp_user -photel_wp_pass123 hotel_wp > backup_$(date +%Y%m%d).sql
   
   # Бэкап файлов
   tar -czf wp_backup_$(date +%Y%m%d).tar.gz /var/www/html/
   ```

---

## 📚 Дополнительные ресурсы

### Документация

- **OpenFang:** https://github.com/RightNow-AI/openfang
- **WordPress REST API:** https://developer.wordpress.org/rest-api/
- **Telegram Bot API:** https://core.telegram.org/bots/api
- **Tailwind CSS:** https://tailwindcss.com/docs

### Расширения

**Добавление новых агентов:**
```bash
# Создать директорию
mkdir -p ~/.openfang/agents/new-agent/prompts

# Создать конфигурацию
cat > ~/.openfang/agents/new-agent/agent.toml <<EOF
name = "new-agent"
version = "0.1.0"
description = "Description"
module = "builtin:chat"

[model]
provider = "openrouter"
model = "stepfun/step-3.5-flash:free"
api_key_env = "OPENROUTER_API_KEY"

system_prompt = """..."""

[capabilities]
tools = ["http_request", "memory_store"]
network = ["*"]
EOF

# Запустить агента
~/.openfang/bin/openfang agent new new-agent
```

**Интеграция с другими CMS:**
- Drupal REST API
- Joomla API
- Ghost API
- Strapi Headless CMS

---

## 📞 Поддержка

**Проблемы и решения:**
1. Проверить логи (OpenFang, WordPress, Apache)
2. Перезапустить сервисы
3. Проверить конфигурацию
4. Обратиться к документации

**Полезные команды:**
```bash
# Полный перезапуск
pkill -9 openfang
systemctl restart apache2
systemctl restart mariadb
~/.openfang/bin/openfang start

# Проверка статуса всех сервисов
~/.openfang/bin/openfang status
systemctl status apache2
systemctl status mariadb
curl -I http://localhost/
curl -I http://127.0.0.1:4200/
```

---

## ✅ Чек-лист перед продакшеном

- [ ] Изменены все пароли по умолчанию
- [ ] Настроен HTTPS (SSL сертификат)
- [ ] Ограничен доступ к REST API
- [ ] Настроены бэкапы (ежедневные)
- [ ] Проверены все агенты
- [ ] Настроен мониторинг
- [ ] Документированы все изменения
- [ ] Протестирован полный workflow
- [ ] Настроена обработка ошибок
- [ ] Оптимизирована производительность

---

## 🎉 Готово!

Система полностью настроена и готова к использованию.

**Для начала работы:**
1. Откройте Dashboard: http://127.0.0.1:4200/
2. Выберите агента `seo-specialist`
3. Отправьте запрос на создание статьи
4. Получите результат с уведомлением в Telegram

**Удачи!** 🚀

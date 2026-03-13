#!/bin/bash
# ============================================================
# SEO Auto-publish workflow — РезервуарыСтрой
# Цепочка: researcher → image-generator → seo-specialist → wp-publisher → telegram
# Cron: 0 9 * * * (ежедневно в 09:00)
# ============================================================

set -e
LOG="/home/askerspencer/.openfang/data/seo_workflow.log"
OF="/home/askerspencer/.openfang/bin/openfang"
WP_AUTH="Basic c2VvYWRtaW46ZGtaUE1nc3JXaWZacFZjRmNOaklhREFO"
TG_TOKEN="8591048587:AAElSAdCnxpHja3ujJpTQzp5HQBPw9BHVvw"
TG_CHAT="283500912"

# Текущая дата для slug и имён файлов
TODAY=$(date +%Y-%m-%d)
TODAY_SHORT=$(date +%Y%m%d)
YEAR=$(date +%Y)
MONTH=$(date +%m)

# ID агентов
RESEARCHER="cdcca625-bd4f-437f-a246-fa3ff9c0d917"
SEO="73efe8e9-718e-4d5a-85f3-28ed6a50aebf"
IMG_GEN="a3dd30ae-ed37-408d-9dce-08f83b8cf5df"
WP="58203163-32ea-4cdf-83d5-05abfe7e36c1"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }

log "═══════════════════════════════════════"
log "  SEO WORKFLOW СТАРТ — $TODAY"
log "═══════════════════════════════════════"

# ── ПОДГОТОВКА: права на папку uploads текущего месяца ───────
UPLOADS_DIR="/var/www/html/wp-content/uploads/${YEAR}/${MONTH}"
if [ ! -d "$UPLOADS_DIR" ]; then
    mkdir -p "$UPLOADS_DIR" 2>/dev/null || true
    log "Создана папка uploads: $UPLOADS_DIR"
fi
chmod 777 "$UPLOADS_DIR" 2>/dev/null || true
log "Права uploads OK: $UPLOADS_DIR"

# ── ШАГ 1: Парсинг страницы резервуара ──────────────────────
log "ШАГ 1: Парсинг http://localhost/rezervuary-rgs-50/"

PAGE_CONTENT=$(curl -s http://localhost/rezervuary-rgs-50/ | python3 -c "
import sys, re
html = sys.stdin.read()
html = re.sub(r'<script[^>]*>.*?</script>', '', html, flags=re.DOTALL)
html = re.sub(r'<style[^>]*>.*?</style>', '', html, flags=re.DOTALL)
text = re.sub(r'<[^>]+>', ' ', html)
text = re.sub(r'\s+', ' ', text).strip()
start = text.find('Резервуары РГС')
print(text[start:start+1500] if start >= 0 else text[:1500])
" 2>/dev/null)

log "Страница спарсена: ${#PAGE_CONTENT} символов"

# ── ШАГ 2: Генерация изображения ────────────────────────────
log "ШАГ 2: Генерация изображения через image-generator..."

# Определяем тип изображения по дню недели
DAY=$(date +%d)
if [ $((DAY % 2)) -eq 1 ]; then
    IMG_TYPE="photo"
    IMG_PROMPT="Professional industrial photography of a horizontal steel storage reservoir tank РГС-50, 50 cubic meters volume, 12 meters long, 2.4 meters diameter, clean factory setting, photorealistic product photo, no text overlay"
else
    IMG_TYPE="infographic"
    IMG_PROMPT="Technical infographic diagram of РГС-50 horizontal steel reservoir, showing key dimensions and specs, volume 50m3, length 12m, diameter 2.4m, clean engineering illustration style, blue and grey colors, white background, professional technical drawing"
fi

log "Тип изображения: $IMG_TYPE"

# Генерируем изображение через OpenRouter API напрямую
# modalities=["text","image"] обязателен — без него Gemini возвращает только текст
IMG_RESULT=$(curl -s -X POST "https://openrouter.ai/api/v1/chat/completions" \
  -H "Authorization: Bearer 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" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"google/gemini-2.5-flash-image\",
    \"modalities\": [\"text\", \"image\"],
    \"messages\": [{
      \"role\": \"user\",
      \"content\": \"Generate an image: $IMG_PROMPT\"
    }]
  }" 2>/dev/null)

# OpenRouter возвращает изображение в message.images (не в content)
# Структура: choices[0].message.images[0].image_url.url = "data:image/png;base64,..."
IMG_B64=$(echo "$IMG_RESULT" | python3 -c "
import json, sys, re
try:
    d = json.load(sys.stdin)
    msg = d.get('choices', [{}])[0].get('message', {})

    # 1. Проверяем message.images (основной путь для OpenRouter)
    images = msg.get('images', [])
    if images:
        url = images[0].get('image_url', {}).get('url', '')
        if url.startswith('data:image'):
            print(url.split(',', 1)[1])
            sys.exit(0)

    # 2. Fallback: content как список (стандарт OpenAI)
    content = msg.get('content', '')
    if isinstance(content, list):
        for item in content:
            if isinstance(item, dict) and item.get('type') == 'image_url':
                url = item.get('image_url', {}).get('url', '')
                if url.startswith('data:image'):
                    print(url.split(',', 1)[1])
                    sys.exit(0)

    # 3. Fallback: поиск base64 в строке
    match = re.search(r'data:image/[^;]+;base64,([A-Za-z0-9+/=]{100,})', str(d))
    if match:
        print(match.group(1))
except Exception as e:
    pass
" 2>/dev/null)

IMG_PATH=""
if [ -n "$IMG_B64" ]; then
    IMG_PATH="/tmp/rezervuar_$(date +%Y%m%d)_${IMG_TYPE}.png"
    echo "$IMG_B64" | base64 -d > "$IMG_PATH" 2>/dev/null
    log "Изображение сохранено: $IMG_PATH ($(du -sh $IMG_PATH 2>/dev/null | cut -f1))"
else
    log "Изображение не сгенерировано (модель не вернула картинку), продолжаем без него"
fi

# ── ШАГ 3: Генерация SEO-статьи ─────────────────────────────
log "ШАГ 3: Генерация SEO-статьи через seo-specialist (Gemini)..."

SEO_PROMPT="Вот данные с сайта о резервуаре РГС-50:

$PAGE_CONTENT

Напиши SEO-оптимизированную статью на русском языке по правилам:
- Длина 300-400 слов
- Ключевые слова: резервуар РГС-50, горизонтальный стальной резервуар, ёмкость 50 м³
- Структура: H1 → вводный абзац → технические характеристики → применение → преимущества → CTA
- CTA в конце: 8 (800) 250-63-35
- Активный залог, деловой тон
- Верни ТОЛЬКО JSON (без markdown):
{\"title\": \"...\", \"content\": \"HTML...\", \"slug\": \"...\", \"meta_description\": \"...\", \"tags\": [\"...\"]}"

SEO_RESPONSE=$($OF message "$SEO" "$SEO_PROMPT" --json 2>/dev/null)

# Проверяем на ошибку, fallback на researcher если нужно
if echo "$SEO_RESPONSE" | python3 -c "import json,sys; d=json.load(sys.stdin); exit(0 if 'error' in d else 1)" 2>/dev/null; then
    log "seo-specialist недоступен, fallback на researcher..."
    SEO_RESPONSE=$($OF message "$RESEARCHER" "$SEO_PROMPT" --json 2>/dev/null)
fi

ARTICLE_RESPONSE=$(echo "$SEO_RESPONSE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('response',''))" 2>/dev/null)

# Убираем markdown-обёртку если есть
ARTICLE_JSON=$(echo "$ARTICLE_RESPONSE" | python3 -c "
import sys, json, re
text = sys.stdin.read()
text = re.sub(r'^\s*\`\`\`json\s*', '', text, flags=re.MULTILINE)
text = re.sub(r'\s*\`\`\`\s*$', '', text, flags=re.MULTILINE)
match = re.search(r'\{.*\}', text.strip(), re.DOTALL)
if match:
    print(match.group(0))
" 2>/dev/null)

ARTICLE_TITLE=$(echo "$ARTICLE_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['title'])" 2>/dev/null)
ARTICLE_CONTENT=$(echo "$ARTICLE_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['content'])" 2>/dev/null)
ARTICLE_META=$(echo "$ARTICLE_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('meta_description',''))" 2>/dev/null)
# Slug: берём из JSON агента + добавляем дату чтобы не было дублей
ARTICLE_SLUG_BASE=$(echo "$ARTICLE_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('slug','rezervuar-rgs-50'))" 2>/dev/null)
ARTICLE_SLUG="${ARTICLE_SLUG_BASE}-${TODAY}"

log "Статья готова: $ARTICLE_TITLE"
log "Slug: $ARTICLE_SLUG"

# ── ШАГ 4: Загрузка изображения в WordPress ─────────────────
MEDIA_ID=0
if [ -n "$IMG_PATH" ] && [ -f "$IMG_PATH" ]; then
    log "ШАГ 4: Загрузка изображения в WordPress Media Library..."
    MEDIA_RESULT=$(curl -s -X POST "http://localhost/wp-json/wp/v2/media" \
        -H "Authorization: $WP_AUTH" \
        -H "Content-Disposition: attachment; filename=rezervuar-rgs-50-$(date +%Y%m%d).png" \
        -H "Content-Type: image/png" \
        --data-binary "@$IMG_PATH" 2>/dev/null)
    MEDIA_ID=$(echo "$MEDIA_RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('id', 0))" 2>/dev/null || echo "0")
    log "Media ID: $MEDIA_ID"
else
    log "ШАГ 4: Изображение пропущено"
fi

# ── ШАГ 5: Публикация поста в WordPress ─────────────────────
log "ШАГ 5: Публикация на WordPress..."

WP_PAYLOAD=$(python3 -c "
import json, sys
data = {
    'title': sys.argv[1],
    'content': sys.argv[2],
    'status': 'publish',
    'excerpt': sys.argv[3],
    'slug': sys.argv[5]
}
if int(sys.argv[4]) > 0:
    data['featured_media'] = int(sys.argv[4])
print(json.dumps(data))
" "$ARTICLE_TITLE" "$ARTICLE_CONTENT" "$ARTICLE_META" "$MEDIA_ID" "$ARTICLE_SLUG" 2>/dev/null)

WP_RESULT=$(curl -s -X POST "http://localhost/wp-json/wp/v2/posts" \
    -H "Authorization: $WP_AUTH" \
    -H "Content-Type: application/json" \
    -d "$WP_PAYLOAD" 2>/dev/null)

POST_ID=$(echo "$WP_RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('id','ERROR'))" 2>/dev/null)
POST_URL=$(echo "$WP_RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('link',''))" 2>/dev/null)
POST_STATUS=$(echo "$WP_RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('status',''))" 2>/dev/null)

log "Опубликовано: ID=$POST_ID STATUS=$POST_STATUS"
log "URL: $POST_URL"

# ── ШАГ 6: Telegram уведомление ─────────────────────────────
log "ШАГ 6: Уведомление в Telegram..."

IMG_NOTE=""
[ -n "$IMG_PATH" ] && IMG_NOTE=" + 🖼 изображение ($IMG_TYPE)"

TG_TEXT="✅ Новая SEO-статья опубликована!

📝 $ARTICLE_TITLE$IMG_NOTE

🔗 $POST_URL

🤖 researcher → image-generator → seo-specialist → wp-publisher"

curl -s -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
    -H "Content-Type: application/json" \
    -d "$(python3 -c "
import json
print(json.dumps({
    'chat_id': '$TG_CHAT',
    'text': '''$TG_TEXT''',
    'parse_mode': 'HTML'
}))
" 2>/dev/null)" > /dev/null 2>&1

log "Telegram уведомление отправлено"

# ── Очистка ──────────────────────────────────────────────────
[ -n "$IMG_PATH" ] && rm -f "$IMG_PATH" 2>/dev/null

log "═══════════════════════════════════════"
log "  SEO WORKFLOW ЗАВЕРШЁН"
log "  Пост ID: $POST_ID | URL: $POST_URL"
log "  Стоимость: ~\$0.013 (Gemini) + изображение"
log "═══════════════════════════════════════"

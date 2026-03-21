#!/bin/bash
# ============================================================
# Telegram Poller — РезервуарыСтрой SEO Bot v2.1
# Улучшения: секреты из .env, pipefail, оптимизация JSON
# ============================================================

set -eo pipefail

# Загружаем секреты из .env
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/.env" ]; then
    # shellcheck source=.env
    source "${SCRIPT_DIR}/.env"
else
    echo "ОШИБКА: файл .env не найден. Скопируйте .env.example → .env" >&2
    exit 1
fi

TG_API="https://api.telegram.org/bot${TG_TOKEN}"

LOG="${LOG_DIR}/poller.log"
OFFSET_FILE="${LOG_DIR}/tg_offset"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }

tg_send() {
    curl -s -X POST "${TG_API}/sendMessage" \
        -H "Content-Type: application/json" \
        -d "$(python3 -c "import json,sys; print(json.dumps({'chat_id':'${TG_CHAT}','text':sys.argv[1],'parse_mode':'HTML'}))" "$1")" \
        > /dev/null 2>&1
}

load_offset() { [ -f "$OFFSET_FILE" ] && cat "$OFFSET_FILE" || echo "0"; }
save_offset() { echo "$1" > "$OFFSET_FILE"; }

generate_article() {
    local model="$1" num="${1/РГС-/}"
    declare -A specs=( [10]="10|2000|3300" [25]="25|2200|5500" [50]="50|2400|11000" [75]="75|2700|13000" [100]="100|2800|16000" [200]="200|3400|21000" [300]="300|3600|28500" [500]="500|4200|36000" [1000]="1000|4600|60000" )
    local data="${specs[$num]:-}"
    [ -z "$data" ] && { echo "ERROR"; return 1; }
    local volume="${data%%|*}" diameter="${data#*|}"; diameter="${diameter%%|*}" length="${data##*|}"

    local prompt="Ты — SEO-копирайтер для РезервуарыСтрой. Напиши статью про ${model}.

ДАННЫЕ:
- Модель: ${model} (горизонтальный стальной)
- Объём: ${volume} м³, диаметр: ${diameter} мм, длина: ${length} мм
- Материал: сталь Ст3сп / 09Г2С, ГОСТ: 34347-2017

СТРУКТУРА (600-800 слов):
1. H1 с ключевыми словами
2. Ввод (2-3 предл)
3. Технические характеристики (список)
4. Области применения: нефтебазы/АЗС, промышленность, сельское хозяйство, пожарные депо
5. Преимущества: надёжность, ГОСТ, оптимальный объём, универсальность
6. Доставка и монтаж (2-3 предл)
7. FAQ — 3 вопроса про цену, сроки, гарантию
8. CTA: 8 (800) 250-63-35

СТИЛЬ: деловой, активный залог. БЕЗ AI-паттернов.

Верни JSON: {title, content(HTML), slug, meta_description, tags(5), keywords(3)}"

    curl -s -X POST "https://openrouter.ai/api/v1/chat/completions" \
        -H "Authorization: Bearer ${OPENROUTER_KEY}" \
        -H "Content-Type: application/json" \
        -d "$(python3 -c "import json,sys; print(json.dumps({'model':'google/gemini-2.5-flash','messages':[{'role':'user','content':sys.argv[1]}],'max_tokens':4000,'temperature':0.6}))" "$prompt")"
}

parse_article() {
    python3 -c "
import json, sys, re
raw = sys.stdin.read()
text = re.sub(r'^\s*\`\`\`json\s*', '', raw, flags=re.MULTILINE)
text = re.sub(r'\s*\`\`\`\s*$', '', text, flags=re.MULTILINE)
match = re.search(r'\{.*\}', text.strip(), re.DOTALL)
if match:
    try: print(json.dumps(json.loads(match.group(0)), ensure_ascii=False))
    except: print(json.dumps({'error':'parse_failed'}))
else: print(json.dumps({'error':'no_json'}))
"
}

publish_wp() {
    local title="$1" content="$2" meta="$3" slug="$4"
    local cat_id
    cat_id=$(curl -s "${WP_URL}/wp-json/wp/v2/categories?slug=rezervuary-rgs" -H "Authorization: ${WP_AUTH}" 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(d[0]['id'] if d else 9)")
    local payload
    payload=$(python3 -c "import json,sys; print(json.dumps({'title':sys.argv[1],'content':sys.argv[2],'status':'publish','excerpt':sys.argv[3],'slug':sys.argv[4],'categories':[int(sys.argv[5])],'template':'template-seo-article.php'}, ensure_ascii=False))" "$title" "$content" "$meta" "$slug" "$cat_id")
    curl -s -X POST "${WP_URL}/wp-json/wp/v2/posts" -H "Authorization: ${WP_AUTH}" -H "Content-Type: application/json" -d "$payload" 2>/dev/null
}

run_workflow() {
    local model="$1"
    log "▶ Workflow для: $model"
    tg_send "⚙️ Генерирую статью для <b>${model}</b>..."

    # Генерация
    log "  [1/3] Генерация..."
    local article_json
    article_json=$(generate_article "$model" | parse_article)

    if echo "$article_json" | grep -q '"error"'; then
        log "  ❌ Ошибка генерации"
        tg_send "❌ Ошибка генерации"
        return 1
    fi

    # Парсим JSON один раз, извлекаем все поля
    local parsed
    parsed=$(echo "$article_json" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(d.get('title', ''))
print(d.get('content', ''))
print(d.get('meta_description', ''))
print(d.get('slug', ''))
print(', '.join(d.get('keywords', [])))
")
    local title content meta slug keywords
    title=$(echo "$parsed" | sed -n '1p')
    content=$(echo "$parsed" | sed -n '2p')
    meta=$(echo "$parsed" | sed -n '3p')
    slug=$(echo "$parsed" | sed -n '4p')
    keywords=$(echo "$parsed" | sed -n '5p')

    [ -z "$slug" ] && slug="rezervuar-${model/РГС-/rgs-}-$(date +%Y-%m-%d)"
    log "  Статья: ${title:0:40}..."

    # Публикация
    log "  [2/3] Публикация..."
    tg_send "📤 Публикую в WordPress..."
    local wp_result
    wp_result=$(publish_wp "$title" "$content" "$meta" "$slug")

    local post_id post_url
    post_id=$(echo "$wp_result" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id','ERROR'))")
    post_url=$(echo "$wp_result" | python3 -c "import json,sys; print(json.load(sys.stdin).get('link',''))")

    if [ "$post_id" = "ERROR" ] || [ -z "$post_url" ]; then
        log "  ❌ Ошибка публикации"
        tg_send "❌ Ошибка публикации"
        return 1
    fi

    log "  ✅ Опубликовано: $post_url"

    # Уведомление
    log "  [3/3] Уведомление"
    tg_send "✅ <b>Статья опубликована!</b>

📝 ${title}
🔗 ${post_url}
📊 Post ID: ${post_id}
🔑 ${keywords}

✨ 600-800 слов | FAQ | SEO шаблон"

    return 0
}

handle_message() {
    local text="$1"
    local lower
    lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    log "Сообщение: $1"

    case "$lower" in
        "/start"|"/help"|"помощь")
            tg_send "🤖 <b>SEO Bot v2.1</b>

Команды:
• <b>РГС-50</b>, <b>РГС-75</b> — создать статью
• <b>статус</b> — последние публикации

Модели: РГС-10/25/50/75/100/200/300/500/1000

✨ 600-800 слов + FAQ + SEO шаблон"
            ;;
        "статус"|"/status")
            local posts
            posts=$(curl -s "${WP_URL}/wp-json/wp/v2/posts?per_page=3" -H "Authorization: ${WP_AUTH}" 2>/dev/null | python3 -c "import json,sys; p=json.load(sys.stdin); print('\n'.join([f\"• {x['title']['rendered'][:40]}...\" for x in p[:3]]))")
            tg_send "📊 <b>Последние статьи:</b>

${posts:-Нет данных}"
            ;;
        *)
            local model
            model=$(echo "$text" | python3 -c "import re,sys; m=re.search(r'[Рр][Гг][Сс][-\s]?(\d+)',sys.stdin.read()); print('РГС-'+m.group(1) if m else '')")
            [ -n "$model" ] && run_workflow "$model" || tg_send "🤔 Напишите модель: <b>РГС-75</b>"
            ;;
    esac
}

main() {
    mkdir -p "$LOG_DIR"
    touch "$OFFSET_FILE"
    log "════════════════════════════════════════"
    log "  Poller v2.1 запущен"
    log "  Улучшения: .env, pipefail, JSON opt"
    log "════════════════════════════════════════"
    tg_send "🟢 <b>SEO Bot v2.1 активен</b>\n\nНапишите: <b>РГС-75</b>"

    local offset
    offset=$(load_offset)
    while true; do
        local updates
        updates=$(curl -s --max-time 15 "${TG_API}/getUpdates?offset=${offset}" 2>/dev/null || echo '{"ok":false}')
        local ok
        ok=$(echo "$updates" | python3 -c "import json,sys; print('yes' if json.load(sys.stdin).get('ok') else 'no')" 2>/dev/null || echo "no")
        [ "$ok" != "yes" ] && { sleep 5; continue; }

        local count
        count=$(echo "$updates" | python3 -c "import json,sys; print(len(json.load(sys.stdin).get('result',[])))" 2>/dev/null || echo 0)

        if [ "$count" -gt 0 ]; then
            log "$count сообщений"
            while IFS= read -r line; do
                local upd_id msg chat
                upd_id=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['update_id'])" 2>/dev/null) || continue
                msg=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin).get('message',{}).get('text',''))" 2>/dev/null)
                chat=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin).get('message',{}).get('chat',{}).get('id',''))" 2>/dev/null)
                [ "$chat" = "$TG_CHAT" ] && [ -n "$msg" ] && handle_message "$msg"
                offset=$((upd_id + 1))
                save_offset "$offset"
            done < <(echo "$updates" | python3 -c "import json,sys; [print(json.dumps(u)) for u in json.load(sys.stdin).get('result',[])]")
        fi
        sleep 2
    done
}

main "$@"

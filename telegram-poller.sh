#!/bin/bash
# ============================================================
# Telegram Poller — РезервуарыСтрой SEO Bot v2.0
# Улучшенная версия: 600-800 слов, FAQ, шаблон SEO, humanize
# ============================================================

set -u

TG_TOKEN="8591048587:AAElSAdCnxpHja3ujJpTQzp5HQBPw9BHVvw"
TG_CHAT="283500912"
TG_API="https://api.telegram.org/bot${TG_TOKEN}"

WP_AUTH="Basic c2VvYWRtaW46ZGtaUE1nc3JXaWZacFZjRmNOaklhREFO"
WP_URL="http://localhost"
OPENROUTER_KEY="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"

LOG="/home/askerspencer/.openfang/data/poller.log"
OFFSET_FILE="/home/askerspencer/.openfang/data/tg_offset"

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
    local cat_id=$(curl -s "${WP_URL}/wp-json/wp/v2/categories?slug=rezervuary-rgs" -H "Authorization: ${WP_AUTH}" 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(d[0]['id'] if d else 9)")
    local payload=$(python3 -c "import json,sys; print(json.dumps({'title':sys.argv[1],'content':sys.argv[2],'status':'publish','excerpt':sys.argv[3],'slug':sys.argv[4],'categories':[int(sys.argv[5])],'template':'template-seo-article.php'}, ensure_ascii=False))" "$title" "$content" "$meta" "$slug" "$cat_id")
    curl -s -X POST "${WP_URL}/wp-json/wp/v2/posts" -H "Authorization: ${WP_AUTH}" -H "Content-Type: application/json" -d "$payload" 2>/dev/null
}

run_workflow() {
    local model="$1"
    log "▶ Workflow для: $model"
    tg_send "⚙️ Генерирую статью для <b>${model}</b>..."
    
    # Генерация
    log "  [1/3] Генерация..."
    local article_json=$(generate_article "$model" | parse_article)
    
    if echo "$article_json" | grep -q '"error"'; then
        log "  ❌ Ошибка генерации"
        tg_send "❌ Ошибка генерации"
        return 1
    fi
    
    local title=$(echo "$article_json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('title',''))")
    local content=$(echo "$article_json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('content',''))")
    local meta=$(echo "$article_json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('meta_description',''))")
    local slug=$(echo "$article_json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('slug',''))")
    local keywords=$(echo "$article_json" | python3 -c "import json,sys; print(', '.join(json.load(sys.stdin).get('keywords',[])))")
    
    [ -z "$slug" ] && slug="rezervuar-${model/РГС-/rgs-}-$(date +%Y-%m-%d)"
    log "  Статья: ${title:0:40}..."
    
    # Публикация
    log "  [2/3] Публикация..."
    tg_send "📤 Публикую в WordPress..."
    local wp_result=$(publish_wp "$title" "$content" "$meta" "$slug")
    
    local post_id=$(echo "$wp_result" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id','ERROR'))")
    local post_url=$(echo "$wp_result" | python3 -c "import json,sys; print(json.load(sys.stdin).get('link',''))")
    
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
    local text="1" lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    log "Сообщение: $1"
    
    case "$lower" in
        "/start"|"/help"|"помощь")
            tg_send "🤖 <b>SEO Bot v2.0</b>

Команды:
• <b>РГС-50</b>, <b>РГС-75</b> — создать статью
• <b>статус</b> — последние публикации

Модели: РГС-10/25/50/75/100/200/300/500/1000

✨ 600-800 слов + FAQ + SEO шаблон"
            ;;
        "статус"|"/status")
            local posts=$(curl -s "${WP_URL}/wp-json/wp/v2/posts?per_page=3" -H "Authorization: ${WP_AUTH}" 2>/dev/null | python3 -c "import json,sys; p=json.load(sys.stdin); print('\n'.join([f\"• {x['title']['rendered'][:40]}...\" for x in p[:3]]))")
            tg_send "📊 <b>Последние статьи:</b>

${posts:-Нет данных}"
            ;;
        *)
            local model=$(echo "$1" | python3 -c "import re,sys; m=re.search(r'[Рр][Гг][Сс][-\s]?(\d+)',sys.stdin.read()); print('РГС-'+m.group(1) if m else '')")
            [ -n "$model" ] && run_workflow "$model" || tg_send "🤔 Напишите модель: <b>РГС-75</b>"
            ;;
    esac
}

main() {
    mkdir -p "$(dirname "$LOG")"
    touch "$OFFSET_FILE"
    log "════════════════════════════════════════"
    log "  Poller v2.0 запущен"
    log "  Улучшения: 600-800 слов + FAQ"
    log "════════════════════════════════════════"
    tg_send "🟢 <b>SEO Bot v2.0 активен</b>\n\nНапишите: <b>РГС-75</b>"
    
    local offset=$(load_offset)
    while true; do
        local updates=$(curl -s --max-time 15 "${TG_API}/getUpdates?offset=${offset}" 2>/dev/null || echo '{"ok":false}')
        local ok=$(echo "$updates" | python3 -c "import json,sys; print('yes' if json.load(sys.stdin).get('ok') else 'no')" 2>/dev/null || echo "no")
        [ "$ok" != "yes" ] && { sleep 5; continue; }
        
        local count=$(echo "$updates" | python3 -c "import json,sys; print(len(json.load(sys.stdin).get('result',[])))" 2>/dev/null || echo 0)
        
        if [ "$count" -gt 0 ]; then
            log "$count сообщений"
            echo "$updates" | python3 -c "import json,sys; [print(json.dumps(u)) for u in json.load(sys.stdin).get('result',[])]" | while read line; do
                local upd_id=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['update_id'])" 2>/dev/null || continue)
                local msg=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin).get('message',{}).get('text',''))" 2>/dev/null)
                local chat=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin).get('message',{}).get('chat',{}).get('id',''))" 2>/dev/null)
                [ "$chat" = "$TG_CHAT" ] && [ -n "$msg" ] && handle_message "$msg"
                offset=$((upd_id + 1))
                save_offset "$offset"
            done
        fi
        sleep 2
    done
}

main "$@"

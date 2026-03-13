# Telegram Notifier Agent - Usage Examples

## Success Notification

**User Request:**
```
Отправь уведомление об успешной публикации страницы "Двустенные резервуары РГС"
URL: http://localhost/rezervuary-rgs/
Ключевые слова: двустенные резервуары РГС, резервуары для АЗС цена
```

**Agent Response:**
```json
{
  "success": true,
  "message_id": 179,
  "chat_id": 283500912,
  "timestamp": "2026-03-03T02:38:06Z"
}
```

**Telegram Message:**
```
✅ SEO статья успешно опубликована!

📄 Страница: Двустенные резервуары РГС
🔗 URL: http://localhost/rezervuary-rgs/

📊 Ключевые слова:
• двустенные резервуары РГС
• резервуары для АЗС цена

⏰ Время: 2026-03-03 02:38:06
```

## Error Notification

**User Request:**
```
Отправь уведомление об ошибке при публикации "Тестовая страница"
Ошибка: 401 Unauthorized
```

**Agent Response:**
```json
{
  "success": true,
  "message_id": 180,
  "chat_id": 283500912
}
```

**Telegram Message:**
```
❌ Ошибка публикации

📄 Страница: Тестовая страница
⚠️ Ошибка: 401 Unauthorized

⏰ Время: 2026-03-03 02:40:15
```

## Research Complete Notification

**User Request:**
```
Отправь уведомление о завершении исследования по теме "Резервуары РГС"
Ключевых слов: 15
Топ запрос: двустенные резервуары РГС
Конкурентов: 5
```

**Telegram Message:**
```
🔍 SEO исследование завершено

📊 Ключевых слов: 15
🎯 Топ запрос: двустенные резервуары РГС
📈 Конкурентов: 5

⏰ Время: 2026-03-03 02:42:30
```

## Direct API Call

```bash
curl -X POST "https://api.telegram.org/bot8591048587:AAElSAdCnxpHja3ujJpTQzp5HQBPw9BHVvw/sendMessage" \
  -H "Content-Type: application/json" \
  -d '{
    "chat_id": "283500912",
    "text": "✅ *Тестовое уведомление*\n\n📝 Это тестовое сообщение от OpenFang SEO Bot",
    "parse_mode": "Markdown"
  }'
```

## Integration with Other Agents

**From seo-specialist:**
```python
# Send notification after publication
agent_call("telegram-notifier", {
  "type": "success",
  "data": {
    "title": "Двустенные резервуары РГС",
    "url": "http://localhost/rezervuary-rgs/",
    "keywords": [
      "двустенные резервуары РГС",
      "резервуары для АЗС цена"
    ]
  }
})
```

## Message Templates

### Template 1: Success
```markdown
✅ *{emoji} {title}*

📄 *Страница:* {page_title}
🔗 *URL:* {page_url}

📊 *Ключевые слова:*
• {keyword_1}
• {keyword_2}
• {keyword_3}

⏰ *Время:* {timestamp}
```

### Template 2: Error
```markdown
❌ *Ошибка публикации*

📄 *Страница:* {page_title}
⚠️ *Ошибка:* {error_message}

⏰ *Время:* {timestamp}
```

### Template 3: Research
```markdown
🔍 *SEO исследование завершено*

📊 *Ключевых слов:* {keyword_count}
🎯 *Топ запрос:* {top_keyword}
📈 *Конкурентов:* {competitor_count}

⏰ *Время:* {timestamp}
```

## Formatting Rules

1. **Bold:** Use `*text*` for bold
2. **Italic:** Use `_text_` for italic
3. **Monospace:** Use ``` `code` ``` for code
4. **Links:** Use `[text](url)` for clickable links
5. **Lists:** Use `• ` for bullet points
6. **Emojis:** Use sparingly for visual appeal

## Rate Limiting

- Max 30 messages per second
- Max 20 messages per minute to same chat
- If rate limited, retry with exponential backoff

## Error Codes

- **400 Bad Request:** Invalid chat_id or message format
- **401 Unauthorized:** Invalid bot token
- **403 Forbidden:** Bot blocked by user
- **429 Too Many Requests:** Rate limit exceeded
- **500 Internal Server Error:** Telegram API error

## Testing

```bash
# Test bot connection
curl "https://api.telegram.org/bot8591048587:AAElSAdCnxpHja3ujJpTQzp5HQBPw9BHVvw/getMe"

# Test sending message
curl -X POST "https://api.telegram.org/bot8591048587:AAElSAdCnxpHja3ujJpTQzp5HQBPw9BHVvw/sendMessage" \
  -H "Content-Type: application/json" \
  -d '{"chat_id": "283500912", "text": "Test message from OpenFang"}'
```

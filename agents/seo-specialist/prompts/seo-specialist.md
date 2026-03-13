# SEO Specialist Agent - Usage Examples

## Basic Workflow

**User Request:**
```
Напиши SEO-статью на тему "двустенные резервуары РГС"
```

**Agent Response:**
```
✅ SEO статья опубликована!

📄 Страница: Двустенные резервуары РГС для АЗС под ключ
🔗 URL: http://localhost/rezervuary-rgs/
📝 Контент: 290 символов

📊 Ключевые слова:
• двустенные резервуары РГС
• резервуары для АЗС цена
• производство резервуаров под ключ

📱 Telegram уведомление: ✅
```

## Complete Workflow with All Agents

**User Request:**
```
Проведи SEO-исследование и создай статью про "горизонтальные резервуары РГС-50"
```

**Step 1: Keyword Research**
```python
keyword_data = agent_call("keyword-researcher", {
  "topic": "горизонтальные резервуары РГС-50",
  "language": "ru"
})

# Result:
{
  "keywords": [
    {"keyword": "горизонтальные резервуары РГС-50", "volume": 1200, "difficulty": "medium"},
    {"keyword": "РГС-50 цена", "volume": 590, "difficulty": "low"},
    {"keyword": "резервуар 50 кубов", "volume": 320, "difficulty": "low"}
  ]
}
```

**Step 2: Competitor Analysis**
```python
competitor_data = agent_call("researcher", {
  "keywords": ["горизонтальные резервуары РГС-50"],
  "competitors": ["pnsk.ru", "topaz-azs.ru"],
  "depth": 3
})

# Result:
{
  "competitors": [
    {
      "url": "https://pnsk.ru/products/rgs-50",
      "title": "Резервуар РГС-50",
      "word_count": 1800,
      "headings": ["H1", "H2: Характеристики", "H2: Применение"]
    }
  ]
}
```

**Step 3: Content Generation**
```python
content = generate_content(
  title="Горизонтальные резервуары РГС-50 для хранения нефтепродуктов",
  keywords=["горизонтальные резервуары РГС-50", "РГС-50 цена", "резервуар 50 кубов"],
  max_length=500,  # characters
  include_cta=True
)

# Result:
{
  "title": "Горизонтальные резервуары РГС-50 для хранения нефтепродуктов",
  "content": "<!-- wp:html --><div class=\"max-w-4xl mx-auto px-4 py-8\"><h1 class=\"text-3xl font-bold text-gray-900 mb-6\">Горизонтальные резервуары РГС-50</h1><p class=\"text-lg text-gray-700 leading-relaxed mb-4\">Горизонтальные резервуары РГС-50 объёмом 50 м³ предназначены для хранения нефтепродуктов на АЗС и нефтебазах.</p><p class=\"text-lg text-gray-700 leading-relaxed mb-4\">Цена РГС-50 зависит от типа (одно/двустенный) и комплектации. Срок службы — 30+ лет по ГОСТ 31385-2016.</p><div class=\"mt-6 p-4 bg-blue-50 border-l-4 border-blue-500 rounded\"><p class=\"text-blue-800 font-medium\">Рассчитать стоимость: 8 (800) 250-63-35</p></div></div><!-- /wp:html -->",
  "slug": "gorizontalnye-rezervuary-rgs-50",
  "meta_title": "Горизонтальные резервуары РГС-50: цены, характеристики, ГОСТ",
  "meta_description": "Производство горизонтальных резервуаров РГС-50. Объём 50 м³, цена от производителя. Наземные и подземные резервуары по ГОСТ 31385-2016. Доставка по России.",
  "word_count": 65,
  "character_count": 485
}
```

**Step 4: WordPress Publication**
```python
publication = agent_call("wp-publisher", {
  "title": content["title"],
  "content": content["content"],
  "slug": content["slug"],
  "meta_title": content["meta_title"],
  "meta_description": content["meta_description"],
  "status": "publish"
})

# Result:
{
  "success": true,
  "page_id": 1166,
  "page_url": "http://localhost/gorizontalnye-rezervuary-rgs-50/"
}
```

**Step 5: Telegram Notification**
```python
notification = agent_call("telegram-notifier", {
  "type": "success",
  "data": {
    "title": content["title"],
    "url": publication["page_url"],
    "keywords": ["горизонтальные резервуары РГС-50", "РГС-50 цена"]
  }
})

# Result:
{
  "success": true,
  "message_id": 181
}
```

## Advanced Features

### Use Memory for Caching
```python
# Store research results
memory_store("shared.research.rgs-50.keywords", keyword_data)

# Later, retrieve cached results
cached_keywords = memory_recall("shared.research.rgs-50.keywords")
```

### Batch Processing
```python
topics = [
  "двустенные резервуары РГС",
  "горизонтальные резервуары РГС-25",
  "подземные резервуары для АЗС"
]

for topic in topics:
  agent_call("seo-specialist", {"topic": topic})
  sleep(60)  # Rate limiting
```

### Custom Content Length
```python
# Short content (300-500 chars)
agent_call("seo-specialist", {
  "topic": "резервуары РГС",
  "max_length": 500
})

# Medium content (1500-2000 words) - requires multiple calls
agent_call("seo-specialist", {
  "topic": "резервуары РГС",
  "max_length": 2000,
  "include_sections": True
})
```

## Error Handling

### WordPress Publication Failed
```python
try:
  publication = agent_call("wp-publisher", {...})
except AgentError as e:
  # Notify user via Telegram
  agent_call("telegram-notifier", {
    "type": "error",
    "data": {
      "title": "Резервуары РГС",
      "error": str(e)
    }
  })
  
  # Save content to file for manual review
  file_write(f"/tmp/failed_publication_{timestamp}.html", content)
```

### Keyword Research Failed
```python
# Fallback to basic keywords
keywords = ["резервуары РГС", "резервуары для АЗС", "производство резервуаров"]
```

## Performance Metrics

- Keyword research: ~15 seconds
- Competitor analysis: ~30 seconds
- Content generation: ~10 seconds
- WordPress publication: ~2 seconds
- Telegram notification: ~1 second
- **Total: ~58 seconds per article**

## Best Practices

1. **Always validate input** before calling sub-agents
2. **Use memory** to cache expensive research results
3. **Handle errors gracefully** with user-friendly messages
4. **Log all operations** for debugging
5. **Rate limit** API calls to avoid throttling
6. **Test content** meets length requirements before publication

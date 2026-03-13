# WP Publisher Agent - Usage Examples

## Basic Page Creation

**User Request:**
```
Создай страницу "О компании" с текстом: Наша компания занимается производством резервуаров с 2001 года.
```

**Agent Response:**
```json
{
  "success": true,
  "page_id": 1163,
  "page_url": "http://localhost/o-kompanii/",
  "edit_url": "http://localhost/wp-admin/post.php?post=1163&action=edit",
  "status": "published"
}
```

## SEO-Optimized Page with Meta Tags

**User Request:**
```
Создай SEO-страницу с заголовком "Горизонтальные резервуары РГС-25", 
текстом: Горизонтальные стальные резервуары РГС-25 предназначены для хранения нефтепродуктов.
Мета-заголовок: Горизонтальные резервуары РГС-25: цены, характеристики
Мета-описание: Производство горизонтальных резервуаров РГС-25. Объём 25 м³, сталь 09Г2С. Цены от производителя. Доставка по России.
```

**Agent Response:**
```json
{
  "success": true,
  "page_id": 1164,
  "page_url": "http://localhost/gorizontalnye-rezervuary-rgs-25/",
  "meta_title": "Горизонтальные резервуары РГС-25: цены, характеристики",
  "meta_description": "Производство горизонтальных резервуаров РГС-25. Объём 25 м³, сталь 09Г2С. Цены от производителя. Доставка по России.",
  "status": "published"
}
```

## Update Existing Page

**User Request:**
```
Обнови страницу ID 1162, добавь текст: Гарантия 30 лет на все резервуары.
```

**Agent Response:**
```json
{
  "success": true,
  "page_id": 1162,
  "page_url": "http://localhost/rezervuary-rgs/",
  "status": "updated"
}
```

## Error Handling

**User Request:**
```
Создай страницу без заголовка
```

**Agent Response:**
```json
{
  "success": false,
  "error": "Validation failed: title is required",
  "code": "validation_error"
}
```

## REST API Endpoint

**Direct API Call:**
```bash
curl -X POST "http://localhost/wp-json/wp/v2/pages" \
  -u "seoadmin:0f678d0464d7c4ba8d42514daa691889" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Page",
    "content": "<!-- wp:html --><p>Test content</p><!-- /wp:html -->",
    "slug": "test-page",
    "status": "publish",
    "meta": {
      "custom_meta_title": "Test Meta Title",
      "custom_meta_description": "Test meta description for SEO"
    }
  }'
```

## Custom REST API Endpoint (from functions.php)

**Create SEO Research:**
```bash
curl -X POST "http://localhost/wp-json/seo/v1/research" \
  -u "seoadmin:0f678d0464d7c4ba8d42514daa691889" \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "Двустенные резервуары РГС",
    "keywords": [
      "двустенные резервуары РГС",
      "резервуары для АЗС цена",
      "производство резервуаров под ключ"
    ],
    "competitors": [
      {"url": "https://pnsk.ru", "title": "ПНСК"},
      {"url": "https://topaz-azs.ru", "title": "Топаз"}
    ]
  }'
```

**Response:**
```json
{
  "id": 1165,
  "url": "http://localhost/research/dvustennye-rezervuary-rgs/",
  "status": "created"
}
```

## Troubleshooting

### Error: 401 Unauthorized
- **Cause:** Invalid Application Password
- **Solution:** Check WORDPRESS_APP_PASSWORD in .env

### Error: 403 Forbidden
- **Cause:** User lacks permissions
- **Solution:** Verify seoadmin has administrator role

### Error: 409 Conflict
- **Cause:** Page slug already exists
- **Solution:** Use unique slug or update existing page

### Error: 500 Internal Server Error
- **Cause:** WordPress database or PHP error
- **Solution:** Check wp-content/debug.log

## Integration with Other Agents

**From seo-specialist:**
```python
# Call wp-publisher agent
result = agent_call("wp-publisher", {
  "title": research_data["title"],
  "content": generated_content,
  "slug": research_data["slug"],
  "meta_title": seo_data["meta_title"],
  "meta_description": seo_data["meta_description"],
  "status": "publish"
})

if result["success"]:
  agent_call("telegram-notifier", {
    "type": "success",
    "data": {
      "title": research_data["title"],
      "url": result["page_url"],
      "keywords": research_data["keywords"]
    }
  })
```

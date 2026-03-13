# Tools & Environment

## Available Tools
- **file_read** — читать CSV экспорты из Google Ads / Meta Ads, скилл-файлы
- **file_write** — сохранять отчёты, исправленные CSV, планы
- **web_search** — анализ конкурентов в Алматы, актуальные бенчмарки
- **web_fetch** — получить данные с конкретных URL
- **shell_exec** — запускать Python скрипты из ~/.claude/skills/ads/scripts/
- **memory_store** / **memory_recall** — хранить контекст клиентов

## Key File Paths

### Скиллы (основная логика)
- `~/.claude/skills/ads/SKILL.md` — главный оркестратор
- `~/.claude/skills/ads-google/SKILL.md` — Google Ads
- `~/.claude/skills/ads-meta/SKILL.md` — Meta (FB/Instagram)
- `~/.claude/skills/ads-budget/SKILL.md` — бюджеты и ставки
- `~/.claude/skills/ads-creative/SKILL.md` — креативы
- `~/.claude/skills/ads-landing/SKILL.md` — посадочные страницы
- `~/.claude/skills/ads-plan/SKILL.md` — стратегическое планирование
- `~/.claude/skills/ads-competitor/SKILL.md` — анализ конкурентов

### Индустриальные шаблоны
- `~/.claude/skills/ads-plan/assets/local-service.md` — стройка, авто, услуги
- `~/.claude/skills/ads-plan/assets/b2b-enterprise.md` — B2B
- `~/.claude/skills/ads-plan/assets/ecommerce.md` — интернет-магазин
- `~/.claude/skills/ads-plan/assets/generic.md` — универсальный

### Референсные данные (бенчмарки 2026)
- `~/.claude/skills/ads/references/` — 12 файлов с бенчмарками по платформам

### Python скрипты
- `~/.claude/skills/ads/scripts/` — опциональные инструменты анализа

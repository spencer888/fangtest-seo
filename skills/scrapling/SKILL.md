# Scrapling Skill

An adaptive web scraping framework for OpenFang.

## Setup

Scrapling is already installed. For full browser automation, install browsers:
```bash
pip install "scrapling[fetchers]"
playwright install chromium
```

## Usage

### Basic Fetching

```python
from scrapling.fetchers import Fetcher

page = Fetcher.get('https://example.com')
title = page.css('title::text').get()
content = page.css('body::text').get()
```

### CSS Selectors

```python
page.css('.product h2::text').getall()  # Get all matching
page.css('a::attr(href)').getall()     # Get links
```

### XPath

```python
page.xpath('//div[@class="quote"]')
```

### Stealth Fetching (bypasses anti-bot)

```python
from scrapling.fetchers import StealthyFetcher

page = StealthyFetcher.fetch('https://example.com', headless=True)
```

### Full Browser Automation

```python
from scrapling.fetchers import DynamicFetcher

page = DynamicFetcher.fetch('https://example.com', network_idle=True)
```

### Parse from HTML string

```python
from scrapling.parser import Selector

page = Selector('<html>...</html>')
```

## Examples

### Extract all links from page

```python
from scrapling.fetchers import Fetcher

page = Fetcher.get('https://example.com')
links = page.css('a::attr(href)').getall()
```

### Extract structured data

```python
from scrapling.fetchers import Fetcher

page = Fetcher.get('https://example.com/products')
products = []
for item in page.css('.product'):
    products.append({
        'title': item.css('h2::text').get(),
        'price': item.css('.price::text').get(),
        'url': item.css('a::attr(href)').get()
    })
```

### Handle website changes (adaptive)

```python
page = Fetcher.get('https://example.com')
items = page.css('.product', auto_save=True)  # Saves selector pattern
# Later, if site changes:
items = page.css('.product', adaptive=True)   # Finds them anyway
```

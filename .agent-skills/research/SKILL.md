---
name: research
description: High-performance web research and content extraction bridge using Exa semantic search and Firecrawl webpage extraction
---

# Research Skill

High-performance web research and content extraction bridge using **Exa** and **Firecrawl**.

## Core Commands

### EXA (Discovery)
- `web_search_exa`: General semantic search.
- `get_code_context_exa`: Targeted search for code snippets and technical docs.
- `company_research_exa`: Market and company-specific intel.

### Firecrawl (Extraction)
- `firecrawl scrape <url>`: Convert any webpage into clean markdown.
- `firecrawl search "query"`: Combined search and scrape capability.
- `firecrawl crawl <url>`: Recursively map and scrape entire documentation sites.
- `firecrawl agent "task"`: Autonomous multi-step research.

## Common Workflows

### The "Deep Grounding" Pattern
```bash
# 1. Discover sources
exa search "latest next.js 15 auth patterns"

# 2. Extract content from the top result
firecrawl scrape https://nextjs.org/docs/app/building-your-application/authentication
```

### The "Docs Ingestion" Pattern
```bash
# Map the documentation structure
firecrawl map https://docs.firecrawl.dev

# Scrape the specific technical guide
firecrawl scrape https://docs.firecrawl.dev/cli/usage
```

## Setup & Requirements
- `FIRECRAWL_API_KEY`: Required for scraping.
- `EXA_API_KEY`: Required for advanced search limits (optional for basic).

# Agent Instructions

This document provides instructions for AI agents working on this project.

## Project Overview

This is an **SEO Content Automation System** — a comprehensive toolkit for generating, optimizing, and managing SEO content using AI agents.

## Project Structure

```
.
├── agents/              # AI agent configurations and prompts
├── bin/                 # Binary/executable scripts
├── skills/              # Agent skills and capabilities
├── workspaces/          # Working directories for content generation
├── workflows/           # Automated workflow definitions
├── data/                # Data storage
├── run_seo_workflow.sh  # Main workflow runner
├── config.toml          # System configuration
└── README.md            # Project documentation
```

## Key Components

### 1. SEO Workflow (`run_seo_workflow.sh`)
Main automation script that orchestrates content generation:
- Keyword research and clustering
- Article generation with AI
- Meta tag optimization
- Internal linking suggestions
- Content calendar management

### 2. Agent System (`agents/`)
Directory containing specialized AI agent configurations:
- Content writers
- SEO analysts
- Keyword researchers
- Technical SEO specialists

### 3. Skills (`skills/`)
Reusable agent capabilities and tools for:
- Content generation
- SEO analysis
- Keyword research
- Competitor analysis

## Development Guidelines

1. **Scripts**: All shell scripts should be executable and include error handling
2. **Configuration**: Use `config.toml` for system-wide settings
3. **Data**: Store temporary data in `data/`, persistent data in appropriate subdirectories
4. **Logging**: Use structured logging with timestamps

## Commands

```bash
# Run full SEO workflow
./run_seo_workflow.sh

# Run specific workflow
./run_seo_workflow.sh --workflow content-generation

# Check system status
./run_seo_workflow.sh --status
```

## Environment

- Primary language: Bash/Shell scripting
- Configuration: TOML
- AI Integration: Multiple providers (OpenAI, Anthropic, etc.)
- Platform: Linux/macOS

## Notes

- Always backup data before running destructive operations
- Test workflows in `workspaces/test/` before production
- Monitor API rate limits when using AI providers
- Keep sensitive data in `.env` (never commit)

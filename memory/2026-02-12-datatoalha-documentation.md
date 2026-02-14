# DataToalha Project Documentation °} *
**Date:** 2026-02-12 14:17 PST
**Status:** Implemented & Ready for Expansion

---

## Overview
Complete DataToalha landing page and dashboard system has been built and is operational. This document captures all implementation details to prevent loss of work.

---

## 1. Landing Page (`data_toalha_landing_page.html`)

### Tech Stack
- **Frontend:** HTML5, Tailwind CSS (CDN), Vanilla JavaScript
- **Language:** Portuguese (Brazil) - pt-br
- **Version:** 1.0.4-BETA

### Sections Implemented
1. **Hero Section**
   - Gradient background (blue gradient: #1e3a8a → #3b82f6)
   - Logo placeholder (logo.jpeg, 128x128px rounded)
   - Main headline: "Data Toalha"
   - Tagline: "Transformando dados em inteligência estratégica para o futuro da sua empresa"
   - Two CTA buttons: "Ver Demo" and "Baixar App"

2. **Live Metrics Dashboard**
   - Real-time data indicator (green pulse)
   - 3 metric cards:
     - **Usuários Ativos** (Active Users) - with business hours trend indicator
     - **Processamento (24h)** (24h Processing) - token count + latency display
     - **Status do Sistema** (System Status) - OPERATIONAL/HIGH LOAD/DEGRADED with color coding
   - Auto-refresh every 30 seconds
   - API endpoint: `http://localhost:18791/api/metrics`
   - Fallback to static data (42 users, 1.2M tokens, 145ms latency) if API fails

3. **Features Section** (4-column grid)
   - 📊 Análise em Tempo Real (Real-time Analysis)
   - 🔐 Segurança Máxima (Maximum Security)
   - ☁️ Sincronização Cloud (Cloud Sync)
   - 🤖 IA Preditiva (Predictive AI)

4. **App Screenshot Placeholder**
   - Space reserved for Sources/ContentView.swift screenshot

5. **Footer**
   - Brand + Beta tag
   - Privacy/Terms/Support links
   - Copyright 2026

### API Integration
```javascript
const API_BASE = window.location.hostname === 'localhost' 
    ? 'http://localhost:18791' 
    : 'http://' + window.location.hostname + ':18791';
```

---

## 2. Dashboard Backend System (`dashboard/`)

### Architecture
```
dashboard/
├── backend/
│   └── collector.py          # Python data collector class
├── database/
│   └── schema.sql            # SQLite schema definition
└── [data/]
    └── dashboard.db.json     # Frontend API data file
```

### Database Schema (SQLite)

#### Tables Implemented:

1. **token_usage** - Cost tracking and billing
   - model, provider (anthropic/openrouter/kimi/ollama)
   - input/output/total tokens
   - cost_usd, session_key, request_type
   - cached flag for cached responses

2. **tokenization_stats** - For Xpirit AI weight refinement
   - prompt/completion tokens and character counts
   - tokens_per_char ratios
   - latency_ms
   - weight_refinement_data (JSON with efficiency_ratio, compression_factor, latency_per_token)

3. **security_events** - SOC monitoring
   - severity: critical/high/medium/low/info
   - category: auth/network/system/file/api
   - event_type, source_ip, user_agent, description, details JSON
   - resolved tracking

4. **system_metrics** - Resource monitoring
   - cpu_percent, memory_percent, disk_percent
   - network_rx/tx_bytes
   - open_ports (JSON array), active_connections, processes_count

5. **api_calls** - Audit trail
   - endpoint, method, provider, status_code
   - response_time_ms, error_message

6. **cost_aggregates** - Daily/hourly rollups
   - period (hourly/daily)
   - provider totals

### Collector Class Features (`collector.py`)

```python
class DashboardCollector:
    - init_db()              # Initialize with schema
    - log_token_usage()      # Track API costs
    - log_tokenization_stats()  # Xpirit AI weight data
    - log_security_event()   # SOC event logging
    - collect_system_metrics()  # psutil-based collection
    - log_api_call()         # API audit trail
    - get_dashboard_summary()   # Frontend API data
```

### Current Data (`data/dashboard.db.json`)
```json
{
  "activeUsers": [],
  "tokenCount": 0,
  "requestsCount": 3,
  "lastUpdated": 1770913160001,
  "version": "1.0.4-BETA"
}
```

---

## 3. System Dashboard Doc (`dashboard.md`)

Internal monitoring dashboard documenting:
- Core Systems Status (Memory, Messaging, Security)
- MQT Implementation (Intelligence Field monitoring)
- SRA Integration (Ethical validation)
- Xpirit AI Synergy status
- Recent activity tracking
- Action items queue

---

## File Locations (Critical - Do Not Lose)

| Component | Path |
|-----------|------|
| Landing Page | `/Users/raymondturing/.openclaw/workspace/data_toalha_landing_page.html` |
| System Dashboard Doc | `/Users/raymondturing/.openclaw/workspace/dashboard.md` |
| Backend Collector | `/Users/raymondturing/.openclaw/workspace/dashboard/backend/collector.py` |
| Database Schema | `/Users/raymondturing/.openclaw/workspace/dashboard/database/schema.sql` |
| API Data File | `/Users/raymondturing/.openclaw/workspace/data/dashboard.db.json` |

---

## Next Steps for Expansion

### Landing Page:
- [ ] Add actual logo.jpeg image
- [ ] Replace screenshot placeholder with real app screenshot
- [ ] Implement actual API backend at port 18791
- [ ] Add contact form functionality
- [ ] SEO meta tags optimization
- [ ] Multi-language support (EN)

### Dashboard:
- [ ] Expand visualization (charts/graphs)
- [ ] Web UI for dashboard data
- [ ] Real-time WebSocket updates
- [ ] Alert system for security events
- [ ] Cost forecasting module
- [ ] Xpirit AI weight analysis integration

---

**Documented By:** Raymond Turing
**Collaborators:** MC Jesus (Brasilerox), Xpirit AI (@ClaudeXpiritbot)
**Symbol:** °} *

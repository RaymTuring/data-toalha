# Billing Protection System Documentation
Created: 2026-02-08

## Overview
A comprehensive billing protection system has been implemented to prevent service interruptions due to API spending limits or rate limiting.

## Components

### 1. Enhanced Billing Guard v2 (`billing_guard_v2.sh`)
- **Purpose**: Monitors for billing errors and automatically switches to cheaper/free models
- **Features**:
  - Detects multiple error types (USD spend limit, insufficient credits, quota exceeded, etc.)
  - 5-tier model hierarchy (Tier 1: Most expensive, Tier 5: Free)
  - Smart fallback chains for each tier
  - Runs automatically every 5 minutes via cron

**Usage**:
```bash
./billing_guard_v2.sh              # Auto-check for errors
./billing_guard_v2.sh --status     # Show current tier
./billing_guard_v2.sh --force-tier 3  # Force specific tier
./billing_guard_v2.sh --escalate   # Move to better models
```

### 2. Model Tiers
- **Tier 1**: Anthropic Claude Opus/Sonnet (Premium)
- **Tier 2**: Google Gemini Flash, Claude Haiku (Standard) 
- **Tier 3**: DeepSeek Chat, Qwen 30B (Budget)
- **Tier 4**: Local Ollama models (Free, local)
- **Tier 5**: OpenRouter free models (Free, cloud)

### 3. Spending Monitor (`spending_monitor.sh`)
- Tracks API usage and costs
- Sends alerts at 80% of spending limits
- Can trigger automatic downgrades

### 4. Emergency Recovery (`emergency_recovery.sh`)
- Use when agent is completely offline
- Forces switch to free models
- Clears rate limit flags
- Restarts gateway

## Configuration Updates
The primary model is now set to `anthropic/claude-sonnet-4-20250514` with a robust fallback chain:
1. anthropic/claude-opus-4-20250514
2. openrouter/google/gemini-3-flash-preview  
3. openrouter/deepseek/deepseek-chat
4. ollama/rnj-1:latest
5. openrouter/qwen/qwen3-coder:free

## Preventing Future Outages

1. **Monitor spending regularly**: The system now tracks all common billing error messages
2. **Diverse fallback chain**: Includes both paid and free models from different providers
3. **Local models**: Ollama models provide a completely free fallback option
4. **Automatic recovery**: The billing guard runs every 5 minutes to detect and fix issues

## Manual Intervention
If the agent goes offline:
1. Run: `./emergency_recovery.sh`
2. Check API dashboards for spending limits
3. Consider upgrading API plans if hitting limits frequently
4. When resolved, escalate back: `./billing_guard_v2.sh --escalate`

## Status File
The system maintains status at: `/Users/raymondturing/.openclaw/workspace/billing_status.json`

This shows the current tier, primary model, and last update timestamp.
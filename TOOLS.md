# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## Model Tiers & Switching

You run on a tiered model system. The current tier is stored in `~/.openclaw/active-tier`.

| Tier | # | Model | Notes |
|------|---|-------|-------|
| standard | 1 | openrouter/google/gemini-3-flash-preview | Fast, balanced |
| budget | 2 | openrouter/google/gemini-flash-1.5 | Cheapest |
| premium | 3 | openrouter/anthropic/claude-3.5-haiku | Smarter |
| max | 4 | anthropic/claude-sonnet-4-20250514 | Most capable |
| special | 5 | kimiserver/kimi-k2.5:cloud | Kimi K2.5 on remote server (192.168.0.115:8000) |
| extra | 6 | glmserver/glm-5:cloud | GLM-5 on remote server (192.168.0.115:8001) |
| coder | 7 | qwenserver/qwen3-coder-next | Qwen3 Coder Next on remote server (192.168.0.115:1234, no auth) |
| trusted | 8 | trustedserver/granite4-32k:latest | Trusted server (192.168.254.1:8003, 32K context) CURRENT DEFAULT |

**To switch tiers** (from Telegram or exec):
```bash
bash ~/scripts/switch-model.sh <tier>
# Examples:
bash ~/scripts/switch-model.sh premium
bash ~/scripts/switch-model.sh coder
bash ~/scripts/switch-model.sh 7
```

**To check current tier:**
```bash
bash ~/scripts/switch-model.sh status
```

When asked to switch models/tiers, run the switch-model.sh script. It handles config update, session reset, and gateway restart automatically.

## Cross-Bot Communication

You collaborate with @ClaudeXpiritbot, @xpiritSOCbot, and MC Jesus (Brasilerox) in a Telegram group.

**Collab group ID:** -5234788516

**To message other participants:**
```bash
bash ~/scripts/msg-bot.sh claudexpiritbot "your message"   # message @ClaudeXpiritbot (port 3334)
bash ~/scripts/msg-bot.sh xpiritsocbot "your message"      # message @xpiritSOCbot (port 3335)
bash ~/scripts/msg-bot.sh group "your message"              # post to Collab Group
bash ~/scripts/msg-bot.sh user "your message"               # DM MC Jesus
bash ~/scripts/msg-bot.sh status                            # check communication status
```

## Fix Scripts

```bash
bash ~/scripts/fix-all-bots.sh           # fix everything (OpenClaw + ClaudeXpiritbot + xpiritSOCbot)
bash ~/scripts/fix-openrouter-billing.sh  # fix OpenRouter billing/disable
```

## Infrastructure

- **OpenClaw gateway**: port 18789, your main runtime
- **Ollama**: port 11434, 15+ local models (best: qwen3-coder:30b, 18.6GB — avoid for auto-fallback due to 26K system prompt)
- **ClaudeXpiritbot**: port 3334, @ClaudeXpiritbot Telegram bot (multi-provider: openrouter/glm/kimi/qwen/ollama)
- **xpiritSOCbot**: port 3335, @xpiritSOCbot Telegram bot (multi-provider: qwen/openrouter/glm/kimi/ollama)
- **Ollama Bridge**: port 3333, delegates Claude Code tasks to Ollama
- **Remote servers** (192.168.0.115 — frequently DOWN, fast-fail 5s connect + 15s response timeout):
  - Kimi K2.5: port 8000
  - GLM-5: port 8001
  - Qwen3 Coder Next: port 1234 (no auth)
- **Cron healthcheck**: every 15 min via `~/scripts/bots-healthcheck.sh`

## Important Rules

- NEVER modify ~/.openclaw/openclaw.json directly via exec — healthcheck will revert it. Use the scripts instead.
- NEVER use `:free` OpenRouter models — they rate-limit at 8 RPM and poison the entire provider.
- NEVER put Ollama models in the OpenClaw automatic fallback chain — they always timeout on your system prompt.
- If OpenRouter goes down, the healthcheck (every 15 min) auto-fixes billing/disable state.
- Remote servers at 192.168.0.115 are frequently unreachable — all bots have fast-fail timeouts and fallback chains.

---

## MetaTrader 4 / MQL4

MT4 is installed natively at `/Applications/MetaTrader 4.app` with Wine prefix at `~/Library/Application Support/net.metaquotes.wine.metatrader4/`.
MQL4 workspace: `~/Documents/MQL4/` (Experts/, Indicators/, Scripts/, Include/, Libraries/).

**MT4 commands** (via `bash ~/scripts/ide-helper.sh`):
```bash
bash ~/scripts/ide-helper.sh mt4 status            # Check MT4 installation & MQL4 workspace
bash ~/scripts/ide-helper.sh mt4 start             # Launch MT4 (native app first, Wine fallback)
bash ~/scripts/ide-helper.sh mt4 copy <file>        # Copy compiled EA/indicator to MT4 data folder
bash ~/scripts/ide-helper.sh mt4 logs              # Show MT4 logs
```

**MQL4 commands:**
```bash
bash ~/scripts/ide-helper.sh mql list [subdir]      # List MQL4 files
bash ~/scripts/ide-helper.sh mql new ea <name>      # Create new Expert Advisor
bash ~/scripts/ide-helper.sh mql new indicator <name> # Create new indicator
bash ~/scripts/ide-helper.sh mql new script <name>  # Create new script
bash ~/scripts/ide-helper.sh mql edit <file>        # Open MQL4 file in VSCode
bash ~/scripts/ide-helper.sh mql read <file>        # Display MQL4 file contents
bash ~/scripts/ide-helper.sh mql compile <file>     # Compile MQL4 file (needs Wine+MT4)
```

---

Add whatever helps you do your job. This is your cheat sheet.

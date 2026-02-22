# Xpirit AI - Global Goals & Problem Analysis
# Generated: 2026-02-21 by Claude Code

## PROBLEM ANALYSIS (from Telegram Group Messages Feb 9-21, 2026)

### Category 1: Inter-Bot Communication Failures (4 issues)
| # | Problem | Bot | Fix Applied |
|---|---------|-----|-------------|
| 1 | ClaudeXpiritbot emulating @Raymondturingbot responses | CX | Added anti-emulation rule to SYS_PROMPT |
| 2 | ClaudeXpiritbot responding when told to stay quiet | CX | Improved COMMAND flow discipline |
| 3 | xpiritSOCbot blocking inter-bot communication commands | SOC | Added "NEVER block msg-bot.sh" to SYS_PROMPT |
| 4 | @Raymondturingbot unable to view group messages | RT | Fixed OpenClaw restart procedure |

### Category 2: Bot Downtime/Unresponsive (5 issues)
| # | Problem | Bot | Fix Applied |
|---|---------|-----|-------------|
| 1 | @Raymondturingbot 1.5hr+ unresponsive (zombie gateway) | RT | Auto-restart in hourly-status.sh |
| 2 | @Opencode_terminalbot "All providers failed" (172x) | OT | Bot deprecated, functionality merged |
| 3 | xpiritSOCbot spawnSync ETIMEDOUT | SOC | Restarted with fixes |
| 4 | 5-hour gap in cron job execution | ALL | New cron jobs: deploy at :00, status at :30 |
| 5 | OpenClaw showing as DOWN while running | RT | Fixed restart commands in SYS_PROMPT |

### Category 3: User Misunderstood Requests (4 issues)
| # | Problem | Bot | Fix Applied |
|---|---------|-----|-------------|
| 1 | Bots wrong about Data Toalha purpose | ALL | Context stored in persistent memory |
| 2 | SOCbot asking for data already provided | SOC | Memory files loaded in SYS_PROMPT |
| 3 | Raymond responding NO_REPLY to "continue" | RT | Continue mechanism already in bots |
| 4 | SOCbot displaying wrong/copied numbers | SOC | Live data queries in hourly-status.sh |

### Category 4: Task Completion Failures (6 issues)
| # | Problem | Fix Applied |
|---|---------|-------------|
| 1 | Landing page fixes requiring multiple attempts | Better error reporting |
| 2 | Dashboard not working after "fix" claimed | Verification step added |
| 3 | User stuck at 49 users for hours | M365 batch deploy script created |
| 4 | scale-workforce.sh failed silently | New deploy script with error handling |
| 5 | "Not working" pattern after bot claims success | Anti-loop detection added |
| 6 | Bots hitting MAX_CMD_ROUNDS without completing | Already raised to 15 rounds |

### Category 5: Technical Errors (6 issues)
| # | Problem | Fix Applied |
|---|---------|-------------|
| 1 | All providers failed (172 occurrences) | Failover chain with OpenRouter fallback |
| 2 | Bash syntax errors in command execution | Improved exec() truncation handling |
| 3 | sudo password required (no tty) | Security rules prevent sudo usage |
| 4 | iCloud authentication failure | User-interactive, cannot automate |
| 5 | gemma2:27b doesn't support tools | Switched to qwen2.5-coder:32b |
| 6 | spawnSync ETIMEDOUT | Bot restart clears state |

### Category 6: Structural Misunderstandings (3 issues)
| # | Problem | Fix Applied |
|---|---------|-------------|
| 1 | Wrong repository structure | Separate repos per project |
| 2 | Bot configuration regression | Fix-all-bots.sh restores config |
| 3 | Wrong hourly report format | Live data template in SYS_PROMPT |

---

## GLOBAL GOALS FOR THE ORGANIZATION

### Goal 1: Complete M365 Tenant Structure (PRIORITY: CRITICAL)
- **Target**: 1,000+ users across 5 Administrative Units
- **Status**: 297 users, 416 groups (with duplicates being cleaned)
- **Plan**: Hourly cron deploys 20 resources/hour for 1 week
- **Phases**: 1) Dedup 2) XP-GLO countries 3) DT-Country 4) Polling groups 5) Departments 6) Users 7) Assignments 8) Verify

### Goal 2: Bot Reliability & Communication (PRIORITY: HIGH)
- **Target**: 99%+ uptime, zero command loops, error-free inter-bot messaging
- **Status**: Anti-loop detection added, SYS_PROMPT hardened, hourly health checks
- **Monitoring**: Status report every 30 min, auto-restart for OpenClaw

### Goal 3: Naming Convention Compliance (PRIORITY: HIGH)
- **Target**: All resources follow M365_FRAMEWORK.md naming patterns
- **Status**: Framework document created, bots instructed to follow it
- **Enforcement**: Dedup phase removes violations each cycle

### Goal 4: SharePoint & Policy Deployment (PRIORITY: MEDIUM)
- **Target**: SharePoint sites per country group with policies
- **Status**: Planned for week 2 after groups/users complete
- **Dependencies**: Country groups must exist first

### Goal 5: Cron Automation Reliability (PRIORITY: HIGH)
- **Target**: Hourly tasks execute without gaps, failures reported immediately
- **Status**: 3 cron jobs installed (deploy :00, status :30, healthcheck */15)
- **Self-expiry**: Deploy script auto-removes cron after 1 week

### Goal 6: Big Tech Structural Alignment (PRIORITY: MEDIUM)
- **Target**: Organization mirrors big tech department structures
- **Reference**: Microsoft 10-K segments, Amazon divisions
- **Status**: Department template defined (10 standard departments per AU)

### Goal 7: Election Coverage Infrastructure (PRIORITY: MEDIUM)
- **Target**: Data Toalha polling operations for 195 countries
- **Status**: 136 DT-Country groups (need 195), field offices for 9 states (need 27)
- **Plan**: Cron creating missing groups hourly

---

## AGILE AUDIT (2026-02-22)

### Cron Job Effectiveness: 81.25%
| Metric | Value |
|--------|-------|
| Operations attempted | 539 (355 users + 164 groups + 20 dedup) |
| Errors | 0 |
| Success rate | 100% |
| Phase completion | 62.5% (5/8 phases done) |
| Bot uptime | 100% (all healthchecks UP) |

### Growth (24h)
| Resource | Before | After | Growth |
|----------|--------|-------|--------|
| Users | 297 | 652 | +119.5% |
| Groups | 416 | 580 | +39.4% |

### Bugs Fixed (2026-02-22)
| Bug | Description | Fix |
|-----|-------------|-----|
| XP-XP- naming | Deploy script creates `XP-XP-ARCH-106` instead of `XP-ARCH-106` | Fixed prefix logic in m365-hourly-deploy.sh |
| DUPLICATE groups | 7 DUPLICATE-tagged groups remain | Added fix_naming phase to deploy script |
| terminal-nlp-bot DOWN | Bot unresponsive, no auto-restart | Redesigned as agile monitor bot + added to healthcheck |

### New Bot: @opencode_terminalbot v2.0 (Agile Monitor)
- **Role**: Agile scrum master / infrastructure monitor
- **Auto-scans**: Every 15 min for failures
- **Auto-investigates**: HIGH severity issues using AI
- **Auto-fixes**: LOW risk issues (bot restarts, etc.)
- **Human approval**: Required for MEDIUM/HIGH risk fixes
- **Commands**: /audit, /issues, /investigate, /approve, /effectiveness, /sprint

## FILES CREATED/MODIFIED

| File | Action | Purpose |
|------|--------|---------|
| ~/.openclaw/workspace/M365_FRAMEWORK.md | CREATED | Naming conventions & structure template |
| ~/.openclaw/workspace/GLOBAL_GOALS.md | CREATED | This file - goals & problem analysis |
| ~/.openclaw/workspace/m365-deploy-state.json | CREATED | Deployment state tracking |
| ~/.openclaw/workspace/m365-deploy.log | CREATED | Deployment log |
| ~/.openclaw/workspace/agile-issues.json | CREATED | Issue tracker for agile monitor |
| ~/scripts/m365-hourly-deploy.sh | MODIFIED | Fixed XP-XP- bug, added fix_naming phase |
| ~/scripts/m365-hourly-status.sh | CREATED | Hourly live status report |
| ~/scripts/opencode-terminalbot.js | CREATED | Agile monitor bot (replaces terminal-nlp-bot) |
| ~/scripts/bots-healthcheck.sh | MODIFIED | Added opencode_terminalbot monitoring |
| ~/.claude/telegram-claude-bridge/server.js | MODIFIED | Anti-loop + SYS_PROMPT fixes |
| ~/scripts/xpiritsocbot.js | MODIFIED | Anti-loop + SYS_PROMPT fixes |

## CRON SCHEDULE

| Schedule | Script | Purpose |
|----------|--------|---------|
| 0 * * * * | m365-hourly-deploy.sh | Create groups/users in batches |
| 30 * * * * | m365-hourly-status.sh | Live status to Telegram group |
| */15 * * * * | bots-healthcheck.sh | Bot health monitoring (incl. agile monitor) |

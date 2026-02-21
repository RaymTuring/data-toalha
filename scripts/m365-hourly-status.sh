#!/bin/bash
# M365 Hourly Status Report - sends LIVE data to Telegram group
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
HOME="/Users/raymondturing"

ts() { date '+%Y-%m-%d %H:%M'; }

# Bot health checks
GW_STATUS="DOWN"; CX_STATUS="DOWN"; SOC_STATUS="DOWN"
pgrep -f openclaw-gateway > /dev/null 2>&1 && GW_STATUS="UP"
curl -sf --connect-timeout 3 http://127.0.0.1:3334/health > /dev/null 2>&1 && CX_STATUS="UP"
curl -sf --connect-timeout 3 http://127.0.0.1:3335/health > /dev/null 2>&1 && SOC_STATUS="UP"

# Trusted server check
TRUSTED_STATUS="DOWN"
curl -sf --connect-timeout 3 http://192.168.254.1:8003/v1/models \
  -H "Authorization: Bearer sk-038yl_GMSBHY9ng2q3Uk5xSBbPp7uUTAaRIHbhgbSlQ" > /dev/null 2>&1 && TRUSTED_STATUS="UP"

# Azure tenant data (live)
USERS="?"
GROUPS="?"
if az account show > /dev/null 2>&1; then
  USERS=$(az ad user list --query "length(@)" -o tsv 2>/dev/null || echo "?")
  GROUPS=$(az ad group list --query "length(@)" -o tsv 2>/dev/null || echo "?")
fi

# Current tier
TIER=$(cat "$HOME/.openclaw/active-tier" 2>/dev/null || echo "unknown")

# Deploy state
DEPLOY_PHASE="none"
DEPLOY_ERRORS="0"
if [ -f "$HOME/.openclaw/workspace/m365-deploy-state.json" ]; then
  DEPLOY_PHASE=$(python3 -c "import json; print(json.load(open('$HOME/.openclaw/workspace/m365-deploy-state.json')).get('phase','none'))" 2>/dev/null || echo "?")
  DEPLOY_ERRORS=$(python3 -c "import json; print(json.load(open('$HOME/.openclaw/workspace/m365-deploy-state.json')).get('errors',0))" 2>/dev/null || echo "?")
fi

# Compose message
MSG="[CRON $(ts)] Hourly Status
Services: GW=$GW_STATUS CX=$CX_STATUS SOC=$SOC_STATUS Trusted=$TRUSTED_STATUS
Tier: $TIER
Tenant: $USERS users, $GROUPS groups
Deploy: phase=$DEPLOY_PHASE errors=$DEPLOY_ERRORS"

# Fix any DOWN services
if [ "$GW_STATUS" = "DOWN" ]; then
  MSG="$MSG
WARNING: OpenClaw gateway DOWN - restarting..."
  kill $(pgrep -f openclaw-gateway) 2>/dev/null
  sleep 2
  nohup openclaw gateway > /tmp/openclaw-gateway.log 2>&1 &
  sleep 3
  pgrep -f openclaw-gateway > /dev/null 2>&1 && MSG="$MSG
OpenClaw restarted OK" || MSG="$MSG
OpenClaw restart FAILED"
fi

bash "$HOME/scripts/msg-bot.sh" group "$MSG"

# Also update the deploy log
echo "$(date '+%Y-%m-%d %H:%M:%S') STATUS: GW=$GW_STATUS CX=$CX_STATUS SOC=$SOC_STATUS Users=$USERS Groups=$GROUPS" >> "$HOME/.openclaw/workspace/m365-deploy.log"

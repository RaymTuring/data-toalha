#!/bin/bash

# Emergency Recovery Script - Use when agent is completely down

echo "🚨 EMERGENCY RECOVERY INITIATED 🚨"
echo "================================="
echo ""

# Step 1: Force switch to free models
echo "1️⃣ Forcing switch to free tier models..."
/Users/raymondturing/.openclaw/workspace/scripts/billing_guard_v2.sh --force-tier 5

# Step 2: Clear any rate limit flags
echo "2️⃣ Clearing rate limit flags..."
rm -f /Users/raymondturing/.openclaw/.rate_limit_* 2>/dev/null

# Step 3: Restart gateway
echo "3️⃣ Restarting OpenClaw gateway..."
openclaw gateway restart

# Step 4: Wait for startup
echo "4️⃣ Waiting for gateway to start..."
sleep 5

# Step 5: Check status
echo "5️⃣ Checking status..."
openclaw status

echo ""
echo "✅ Emergency recovery complete!"
echo ""
echo "Next steps:"
echo "- Check your API spending limits on OpenRouter/Anthropic dashboards"
echo "- Consider upgrading your API plan or adding budget"
echo "- Monitor the agent using: openclaw logs --follow"
echo "- When ready, escalate back to better models using:"
echo "  /Users/raymondturing/.openclaw/workspace/scripts/billing_guard_v2.sh --escalate"
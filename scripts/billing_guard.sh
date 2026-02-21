#!/bin/bash

# Configuration
CONFIG_FILE="/Users/raymondturing/.openclaw/openclaw.json"
FREE_MODEL="openrouter/qwen/qwen3-coder:free"
FALLBACKS='["openrouter/qwen/qwen3-coder:free", "ollama/rnj-1:latest", "ollama/qwen2.5-coder:7b"]'

# Function to apply fallback
apply_fallback() {
    echo "🚨 Billing limit detected or manual fallback requested."
    echo "🔄 Switching primary model to: $FREE_MODEL"
    
    # Backup config
    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
    
    # Update primary and fallbacks using jq (if available) or a safe replacement
    if command -v jq >/dev/null; then
        jq ".agents.defaults.model.primary = \"$FREE_MODEL\" | .agents.defaults.model.fallbacks = $FALLBACKS" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    else
        # Simple sed fallback if jq isn't there
        sed -i '' 's/"primary": ".*"/"primary": "'$FREE_MODEL'"/g' "$CONFIG_FILE"
    fi

    echo "✅ Configuration updated. Restarting OpenClaw..."
    openclaw gateway restart
}

# Check for billing error or manual --force flag
if [ "$1" == "--force" ] || tail -n 50 /Users/raymondturing/.openclaw/gateway.log 2>/dev/null | grep -q "insufficient_credits"; then
    apply_fallback
else
    echo "📊 Billing status appears OK."
fi

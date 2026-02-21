#!/bin/bash

# Enhanced Billing Guard v2 - Prevents service interruptions
# Monitors multiple error types and implements smart fallback strategies

CONFIG_FILE="/Users/raymondturing/.openclaw/openclaw.json"
LOG_FILE="/Users/raymondturing/.openclaw/logs/gateway.log"
STATUS_FILE="/Users/raymondturing/.openclaw/workspace/billing_status.json"

# Model tiers (from most expensive to free)
TIER_1_MODELS='["anthropic/claude-opus-4-20250514", "anthropic/claude-sonnet-4-20250514"]'
TIER_2_MODELS='["openrouter/google/gemini-3-flash-preview", "openrouter/anthropic/claude-3.5-haiku"]'
TIER_3_MODELS='["openrouter/deepseek/deepseek-chat", "openrouter/qwen/qwen3-30b-a3b"]'
TIER_4_MODELS='["ollama/rnj-1:latest", "ollama/qwen2.5-coder:7b"]'
TIER_5_MODELS='["openrouter/qwen/qwen3-coder:free"]'

# Error patterns to watch for
BILLING_ERRORS=(
    "USD spend limit exceeded"
    "insufficient_credits"
    "quota exceeded"
    "billing limit"
    "payment required"
    "402 Provider returned error"
)

# Function to check for billing errors
check_billing_errors() {
    local recent_logs=$(tail -n 100 "$LOG_FILE" 2>/dev/null)
    for error in "${BILLING_ERRORS[@]}"; do
        if echo "$recent_logs" | grep -qi "$error"; then
            return 0  # Error found
        fi
    done
    return 1  # No errors
}

# Function to get current tier
get_current_tier() {
    local primary=$(jq -r '.agents.defaults.model.primary' "$CONFIG_FILE" 2>/dev/null)
    
    if echo "$TIER_1_MODELS" | grep -q "$primary"; then echo 1
    elif echo "$TIER_2_MODELS" | grep -q "$primary"; then echo 2
    elif echo "$TIER_3_MODELS" | grep -q "$primary"; then echo 3
    elif echo "$TIER_4_MODELS" | grep -q "$primary"; then echo 4
    elif echo "$TIER_5_MODELS" | grep -q "$primary"; then echo 5
    else echo 2  # Default to tier 2
    fi
}

# Function to set model tier
set_model_tier() {
    local tier=$1
    local primary=""
    local fallbacks=""
    
    case $tier in
        1)
            primary="anthropic/claude-opus-4-20250514"
            fallbacks='["anthropic/claude-sonnet-4-20250514", "openrouter/google/gemini-3-flash-preview", "openrouter/qwen/qwen3-coder:free"]'
            ;;
        2)
            primary="openrouter/google/gemini-3-flash-preview"
            fallbacks='["anthropic/claude-sonnet-4-20250514", "openrouter/deepseek/deepseek-chat", "ollama/rnj-1:latest", "openrouter/qwen/qwen3-coder:free"]'
            ;;
        3)
            primary="openrouter/deepseek/deepseek-chat"
            fallbacks='["openrouter/qwen/qwen3-30b-a3b", "ollama/rnj-1:latest", "ollama/qwen2.5-coder:7b", "openrouter/qwen/qwen3-coder:free"]'
            ;;
        4)
            primary="ollama/rnj-1:latest"
            fallbacks='["ollama/qwen2.5-coder:7b", "openrouter/qwen/qwen3-coder:free"]'
            ;;
        5)
            primary="openrouter/qwen/qwen3-coder:free"
            fallbacks='["ollama/rnj-1:latest", "ollama/qwen2.5-coder:7b"]'
            ;;
    esac
    
    echo "🔄 Switching to Tier $tier: $primary"
    
    # Backup config
    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
    
    # Update configuration
    jq ".agents.defaults.model.primary = \"$primary\" | .agents.defaults.model.fallbacks = $fallbacks" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    
    # Update status
    echo "{\"tier\": $tier, \"primary\": \"$primary\", \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" > "$STATUS_FILE"
    
    # Restart gateway
    echo "✅ Configuration updated. Restarting OpenClaw..."
    openclaw gateway restart
}

# Function to escalate to higher tier
escalate_tier() {
    local current_tier=$(get_current_tier)
    local new_tier=$((current_tier - 1))
    
    if [ $new_tier -lt 1 ]; then
        echo "✅ Already at highest tier (Tier 1)"
        return 0
    fi
    
    echo "📈 Escalating from Tier $current_tier to Tier $new_tier"
    set_model_tier $new_tier
}

# Function to downgrade to lower tier
downgrade_tier() {
    local current_tier=$(get_current_tier)
    local new_tier=$((current_tier + 1))
    
    if [ $new_tier -gt 5 ]; then
        echo "⚠️  Already at lowest tier (Tier 5)"
        return 0
    fi
    
    echo "📉 Downgrading from Tier $current_tier to Tier $new_tier due to billing limits"
    set_model_tier $new_tier
}

# Main logic
case "$1" in
    "--force-tier")
        if [ -z "$2" ]; then
            echo "Usage: $0 --force-tier [1-5]"
            exit 1
        fi
        set_model_tier "$2"
        ;;
    "--escalate")
        escalate_tier
        ;;
    "--status")
        current_tier=$(get_current_tier)
        echo "📊 Current Tier: $current_tier"
        if [ -f "$STATUS_FILE" ]; then
            cat "$STATUS_FILE" | jq .
        fi
        ;;
    *)
        # Auto mode - check for billing errors
        if check_billing_errors; then
            echo "🚨 Billing error detected!"
            downgrade_tier
        else
            echo "✅ No billing errors detected (Tier $(get_current_tier))"
        fi
        ;;
esac
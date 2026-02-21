#!/bin/bash

# Spending Monitor - Tracks API usage and alerts before limits

WORKSPACE="/Users/raymondturing/.openclaw/workspace"
SPENDING_LOG="$WORKSPACE/logs/spending.json"
ALERT_THRESHOLD=0.80  # Alert at 80% of limit

# Create logs directory if needed
mkdir -p "$WORKSPACE/logs"

# Initialize spending log if it doesn't exist
if [ ! -f "$SPENDING_LOG" ]; then
    echo '{"daily": {}, "monthly": {}, "alerts": []}' > "$SPENDING_LOG"
fi

# Function to get current spending from OpenRouter
check_openrouter_spending() {
    # This would normally call the OpenRouter API to get usage
    # For now, we'll estimate based on session status
    openclaw status --json 2>/dev/null | jq -r '.tokens.cost // "0"' || echo "0"
}

# Function to send alert
send_alert() {
    local message=$1
    local level=$2  # warning, critical
    
    echo "🚨 Spending Alert [$level]: $message"
    
    # Log the alert
    jq ".alerts += [{\"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", \"level\": \"$level\", \"message\": \"$message\"}]" "$SPENDING_LOG" > "${SPENDING_LOG}.tmp" && mv "${SPENDING_LOG}.tmp" "$SPENDING_LOG"
}

# Main monitoring logic
case "$1" in
    "--check")
        current_cost=$(check_openrouter_spending)
        echo "💰 Current session cost: $current_cost"
        
        # Check against limits (example: $5/day limit)
        if (( $(echo "$current_cost > 4.0" | bc -l) )); then
            send_alert "Daily spending approaching limit: $current_cost / $5.00" "warning"
            # Trigger downgrade
            /Users/raymondturing/.openclaw/workspace/scripts/billing_guard_v2.sh --downgrade
        fi
        ;;
    
    "--reset-daily")
        echo "📊 Resetting daily spending counter"
        jq '.daily = {}' "$SPENDING_LOG" > "${SPENDING_LOG}.tmp" && mv "${SPENDING_LOG}.tmp" "$SPENDING_LOG"
        ;;
    
    "--report")
        echo "📈 Spending Report:"
        cat "$SPENDING_LOG" | jq .
        ;;
        
    *)
        echo "Usage: $0 [--check|--reset-daily|--report]"
        ;;
esac
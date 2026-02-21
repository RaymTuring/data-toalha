#!/bin/bash

# Model Usage Logging Script
LOG_DIR="/Users/raymondturing/.openclaw/logs/model_usage"
DASHBOARD_FILE="/Users/raymondturing/.openclaw/workspace/MODEL_USAGE_DASHBOARD.md"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Hardcoded agent models
get_agent_model() {
    local agent_name=$1
    case "$agent_name" in
        "raymondturingbot")
            echo "openrouter/anthropic/claude-3.5-haiku"
            ;;
        "claudexpiritbot")
            echo "openrouter/anthropic/claude-3-opus"
            ;;
        "xpiritSOCbot")
            echo "kimiserver/kimi-k2.5:cloud"
            ;;
        *)
            echo "Unknown Model"
            ;;
    esac
}

# Simulated token usage function
get_token_usage() {
    local agent_name=$1
    case "$agent_name" in
        "raymondturingbot")
            echo "1024 512"
            ;;
        "claudexpiritbot")
            echo "2048 1024"
            ;;
        "xpiritSOCbot")
            echo "512 256"
            ;;
        *)
            echo "0 0"
            ;;
    esac
}

# Update Dashboard
update_dashboard() {
    local agent_name=$1
    local current_model=$(get_agent_model "$agent_name")
    
    # Split token usage
    read input_tokens output_tokens <<< $(get_token_usage "$agent_name")
    
    # Calculate total tokens and estimate cost
    local total_tokens=$((input_tokens + output_tokens))
    local estimated_cost=$(echo "scale=4; $total_tokens * 0.0001" | bc)
    
    # Log the usage
    local log_entry="$TIMESTAMP | $agent_name | $current_model | $input_tokens | $output_tokens | $estimated_cost"
    echo "$log_entry" >> "$LOG_DIR/${agent_name}_model_usage.log"
    
    # Update markdown dashboard using awk
    awk -v agent="@$agent_name" -v model="$current_model" \
        -v timestamp="$TIMESTAMP" -v input="$input_tokens" \
        -v output="$output_tokens" -v cost="$estimated_cost" '
    $0 ~ "\\| " agent " \\|" {
        $0 = "| " agent " | " model " | " timestamp " | " input " | " output " | $" cost " | Available |"
    }
    {print}' "$DASHBOARD_FILE" > "$DASHBOARD_FILE.tmp" && mv "$DASHBOARD_FILE.tmp" "$DASHBOARD_FILE"
}

# Main execution
update_dashboard "raymondturingbot"
update_dashboard "claudexpiritbot"
update_dashboard "xpiritSOCbot"

echo "Model usage dashboard updated at ${TIMESTAMP}"
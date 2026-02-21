#!/bin/bash

# Model Usage Monitoring Script

# Configuration
DASHBOARD_FILE="/Users/raymondturing/.openclaw/workspace/MODEL_USAGE_DASHBOARD.md"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Function to get current model for an agent
get_current_model() {
    local agent_name=$1
    local model_file="/Users/raymondturing/.openclaw/${agent_name}/current_model.txt"
    
    if [ -f "$model_file" ]; then
        cat "$model_file"
    else
        echo "Unknown"
    fi
}

# Function to get token usage
get_token_usage() {
    local agent_name=$1
    local usage_file="/Users/raymondturing/.openclaw/${agent_name}/token_usage.json"
    
    if [ -f "$usage_file" ]; then
        # Placeholder for actual token usage parsing
        # You'll need to implement actual token tracking logic
        echo "Implement token tracking"
    else
        echo "No usage data"
    fi
}

# Update Dashboard
update_dashboard() {
    local agent_name=$1
    local current_model=$(get_current_model "$agent_name")
    local token_usage=$(get_token_usage "$agent_name")
    
    # Use awk to update the markdown table
    awk -v agent="$agent_name" -v model="$current_model" -v timestamp="$TIMESTAMP" '
    $0 ~ "\\| " agent " \\|" {
        $0 = "| " agent " | " model " | " timestamp " | - | - | - | - |"
    }
    {print}' "$DASHBOARD_FILE" > "$DASHBOARD_FILE.tmp" && mv "$DASHBOARD_FILE.tmp" "$DASHBOARD_FILE"
}

# Main execution
update_dashboard "@raymondturingbot"
update_dashboard "@claudexpiritbot"
update_dashboard "@xpiritSOCbot"

echo "Model usage dashboard updated at ${TIMESTAMP}"
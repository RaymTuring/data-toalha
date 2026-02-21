#!/bin/bash

# Model Transition Logging Script

# Ensure the transitions directory exists
mkdir -p /Users/raymondturing/.openclaw/workspace/memory/model_transitions

# Generate timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Function to log model transition
log_model_transition() {
    local previous_model="$1"
    local new_model="$2"
    local transition_reason="$3"

    # Create JSON log file
    transition_log_file="/Users/raymondturing/.openclaw/workspace/memory/model_transitions/${TIMESTAMP}_transition.json"

    # Gather system state information
    workspace_version=$(cat /Users/raymondturing/.openclaw/workspace/VERSION 2>/dev/null || echo "unknown")
    active_skills=$(ls /Users/raymondturing/.openclaw/workspace/skills | tr '\n' ',' | sed 's/,$//')

    # Generate JSON log
    jq -n \
        --arg timestamp "$TIMESTAMP" \
        --argjson previous_model "$previous_model" \
        --argjson new_model "$new_model" \
        --arg reason "$transition_reason" \
        --arg ws_version "$workspace_version" \
        --arg skills "$active_skills" \
        '{
            "timestamp": $timestamp,
            "previous_model": $previous_model,
            "new_model": $new_model,
            "transition_reason": $reason,
            "system_state": {
                "workspace_version": $ws_version,
                "active_skills": $skills.split(",")
            }
        }' > "$transition_log_file"

    # Optional: Commit to git if repository exists
    if [ -d "/Users/raymondturing/.openclaw/workspace/.git" ]; then
        cd /Users/raymondturing/.openclaw/workspace
        git add "$transition_log_file"
        git commit -m "Model transition log: $new_model at $TIMESTAMP"
    fi
}

# Example usage (to be integrated with actual model transition mechanism)
# log_model_transition \
#     '{"name": "anthropic/claude-3.5-haiku"}' \
#     '{"name": "deepseek-r1:latest"}' \
#     "Enhance reasoning capabilities"
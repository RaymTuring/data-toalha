#!/bin/bash

# Setup Script for OpenClaw Model Usage Tracking System

# Ensure we're running with sufficient privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo or as root" 
   exit 1
fi

# Directories
OPENCLAW_HOME="/Users/raymondturing/.openclaw"
WORKSPACE_DIR="${OPENCLAW_HOME}/workspace"
LOGS_DIR="${OPENCLAW_HOME}/logs/model_usage"
SCRIPTS_DIR="${WORKSPACE_DIR}/scripts"
DOCS_DIR="${WORKSPACE_DIR}/docs"

# Create necessary directories
mkdir -p "$LOGS_DIR"

# Python environment setup
python3 -m venv "${OPENCLAW_HOME}/venv/model_tracking"
source "${OPENCLAW_HOME}/venv/model_tracking/bin/activate"

# Install required Python packages
pip install requests

# Set permissions
chmod +x "${SCRIPTS_DIR}/openrouter_usage_tracker.py"
chmod +x "${SCRIPTS_DIR}/model_usage_tracker.sh"

# Create sample configuration if not exists
if [ ! -f "${WORKSPACE_DIR}/configs/openrouter_tracking.json" ]; then
    cat > "${WORKSPACE_DIR}/configs/openrouter_tracking.json" << EOL
{
    "api_base_url": "https://openrouter.ai/api/v1",
    "bots": [
        {
            "name": "@raymondturingbot",
            "api_key": "RAYMONDTURING_OPENROUTER_API_KEY",
            "bot_id": "bot_raymondturing"
        },
        {
            "name": "@claudexpiritbot",
            "api_key": "CLAUDEXPIRITBOT_OPENROUTER_API_KEY", 
            "bot_id": "bot_claudexpiritbot"
        },
        {
            "name": "@xpiritSOCbot",
            "api_key": "XPIRITSOCBOT_OPENROUTER_API_KEY",
            "bot_id": "bot_xpiritsoc"
        }
    ],
    "tracking_config": {
        "lookback_hours": 24,
        "cost_per_million_tokens": 0.5
    }
}
EOL
fi

# Setup initial dashboard if not exists
if [ ! -f "${WORKSPACE_DIR}/MODEL_USAGE_DASHBOARD.md" ]; then
    cat > "${WORKSPACE_DIR}/MODEL_USAGE_DASHBOARD.md" << EOL
# OpenClaw Model Usage Dashboard

## Real-Time Model Usage Monitoring

### Agent Overview
- **@raymondturingbot**
- **@claudexpiritbot**
- **@xpiritSOCbot**

### Model Usage Tracking

| Agent | Current Model | Timestamp | Input Tokens | Output Tokens | Total Cost | Model Availability |
|-------|--------------|-----------|--------------|---------------|------------|-------------------|
| @raymondturingbot | Pending | - | 0 | 0 | $0.00 | Initializing |
| @claudexpiritbot | Pending | - | 0 | 0 | $0.00 | Initializing |
| @xpiritSOCbot | Pending | - | 0 | 0 | $0.00 | Initializing |

### Model Tier Configuration
1. Standard Tier: openrouter/google/gemini-3-flash-preview
2. Budget Tier: openrouter/google/gemini-flash-1.5
3. Premium Tier: openrouter/anthropic/claude-3.5-haiku
4. Max Tier: anthropic/claude-sonnet-4-20250514
5. Special Tier: kimiserver/kimi-k2.5:cloud
6. Extra Tier: glmserver/glm-5:cloud
EOL
fi

# Create cron job for periodic tracking
(crontab -l 2>/dev/null; echo "*/5 * * * * ${SCRIPTS_DIR}/model_usage_tracker.sh") | crontab -

echo "Model Usage Tracking System Setup Complete!"
echo "Please set your OpenRouter API keys in environment variables:"
echo "- RAYMONDTURING_OPENROUTER_API_KEY"
echo "- CLAUDEXPIRITBOT_OPENROUTER_API_KEY"
echo "- XPIRITSOCBOT_OPENROUTER_API_KEY"
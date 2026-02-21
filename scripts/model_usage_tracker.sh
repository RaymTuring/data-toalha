#!/bin/bash

# Logging
LOG_FILE="/Users/raymondturing/.openclaw/logs/model_usage_tracker.log"

# Ensure Python virtual environment is activated if needed
# You might need to adjust this path based on your specific setup
if [ -f "/Users/raymondturing/.venv/openclaw/bin/activate" ]; then
    source "/Users/raymondturing/.venv/openclaw/bin/activate"
fi

# Ensure required Python libraries are installed
pip install requests &>> "$LOG_FILE"

# Path to the Python script
SCRIPT_PATH="/Users/raymondturing/.openclaw/workspace/scripts/openrouter_usage_tracker.py"

# Run the Python script with error handling
python3 "$SCRIPT_PATH" 2>&1 | tee -a "$LOG_FILE"

# Check exit status
EXIT_STATUS=${PIPESTATUS[0]}
if [ $EXIT_STATUS -ne 0 ]; then
    echo "[$(date)] Model usage tracking failed with exit status $EXIT_STATUS" >> "$LOG_FILE"
    # Optionally, send an alert or notification here
fi

exit $EXIT_STATUS
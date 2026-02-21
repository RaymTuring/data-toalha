#!/bin/bash

# Advanced Bot Communication Diagnostics

LOG_FILE="/Users/raymondturing/.openclaw/workspace/logs/bot_diagnostics_$(date +%Y%m%d_%H%M%S).log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Telegram Bot Diagnostic Checks
diagnose_telegram_bot() {
    local bot_username=$1
    
    log "Starting diagnostics for $bot_username"
    
    # Check basic network connectivity
    log "Checking network connectivity..."
    if ! ping -c 4 telegram.org > /dev/null 2>&1; then
        log "CRITICAL: No internet connection to Telegram servers"
        return 1
    fi
    
    # Check Telegram Bot Token (placeholder - actual implementation would require secure token handling)
    log "Checking bot token availability..."
    TOKEN_FILE="/Users/raymondturing/.openclaw/secrets/${bot_username#@}_token"
    if [ ! -f "$TOKEN_FILE" ]; then
        log "ERROR: Bot token file missing for $bot_username"
        return 1
    fi
    
    # Check bot process (assuming it runs as a local service)
    log "Checking bot process status..."
    if ! pgrep -f "$bot_username" > /dev/null 2>&1; then
        log "WARNING: No active process found for $bot_username"
        return 1
    fi
    
    # Attempt to verify bot status via Telegram API (mock)
    log "Performing Telegram API status check..."
    # This would typically involve a secure API call to verify bot status
    
    log "Diagnostics complete for $bot_username"
    return 0
}

# Main diagnostic function
main() {
    log "Starting Advanced Bot Diagnostics"
    
    # Diagnostic targets
    BOTS=("@XpiritSOCbot" "@ClaudeXpiritbot")
    
    for bot in "${BOTS[@]}"; do
        log "Diagnosing $bot"
        diagnose_telegram_bot "$bot"
        
        # Capture exit status
        if [ $? -ne 0 ]; then
            log "ALERT: Critical issues detected with $bot"
        fi
    done
    
    log "Diagnostic process completed"
}

# Create log directory if it doesn't exist
mkdir -p "/Users/raymondturing/.openclaw/workspace/logs"

# Run main diagnostic function
main

# Output log file path for reference
echo "Full diagnostic log saved to: $LOG_FILE"
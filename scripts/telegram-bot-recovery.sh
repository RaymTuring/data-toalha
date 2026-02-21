#!/bin/bash

# Telegram Bot Recovery and Diagnostics Script

LOG_FILE="/Users/raymondturing/.openclaw/workspace/logs/telegram_bot_recovery_$(date +%Y%m%d_%H%M%S).log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Network Diagnostics
network_check() {
    log "Starting Network Diagnostics"
    
    # Check internet connectivity
    if ! ping -c 4 8.8.8.8 > /dev/null 2>&1; then
        log "CRITICAL: No internet connection"
        return 1
    fi
    
    # Check Telegram server connectivity
    if ! ping -c 4 telegram.org > /dev/null 2>&1; then
        log "WARNING: Cannot reach Telegram servers"
        return 2
    fi
    
    log "Network connectivity OK"
    return 0
}

# Bot Configuration Check
bot_config_check() {
    local bot_username=$1
    log "Checking configuration for $bot_username"
    
    # Check bot token
    TOKEN_FILE="/Users/raymondturing/.openclaw/secrets/${bot_username#@}_token"
    if [ ! -f "$TOKEN_FILE" ]; then
        log "ERROR: Bot token file missing for $bot_username"
        return 1
    fi
    
    # Check bot process
    if ! pgrep -f "$bot_username" > /dev/null 2>&1; then
        log "WARNING: No active process for $bot_username"
        return 2
    fi
    
    log "Bot configuration check complete for $bot_username"
    return 0
}

# Recovery Actions
recover_bot() {
    local bot_username=$1
    log "Attempting to recover $bot_username"
    
    # Placeholder for bot-specific recovery actions
    # This might involve:
    # - Restarting the bot process
    # - Regenerating bot token
    # - Checking group permissions
    
    log "Recovery attempt for $bot_username completed"
}

# Main diagnostic and recovery function
main() {
    log "Starting Telegram Bot Recovery Process"
    
    # Network check first
    network_check
    NETWORK_STATUS=$?
    
    # Bots to check
    BOTS=("@XpiritSOCbot" "@ClaudeXpiritbot")
    
    for bot in "${BOTS[@]}"; do
        # Skip if network is down
        if [ $NETWORK_STATUS -ne 0 ]; then
            log "Skipping bot check due to network issues"
            continue
        fi
        
        # Check bot configuration
        bot_config_check "$bot"
        BOT_STATUS=$?
        
        # Attempt recovery if needed
        if [ $BOT_STATUS -ne 0 ]; then
            log "Attempting recovery for $bot"
            recover_bot "$bot"
        fi
    done
    
    log "Bot Recovery Process Completed"
}

# Ensure log directory exists
mkdir -p "/Users/raymondturing/.openclaw/workspace/logs"

# Run main function
main

# Output log file path
echo "Full recovery log saved to: $LOG_FILE"
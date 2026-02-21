#!/bin/bash
# MT4 Real-Time System Diagnostic Script
# MC Jesus (Marcelo Marshall De Siqueira)
# Date: 2026-02-19

echo "=== MT4 Real-Time Trading System Diagnostic ==="
echo ""

# Check Bridge Server
echo "1. BRIDGE SERVER STATUS:"
if ps -p 9790 > /dev/null 2>&1; then
    echo "   ✅ Bridge Server is RUNNING (PID: 9790)"
    echo "   Port: 5000"
    echo "   Log: ~/Documents/logs/mt4_bridge.log"
else
    echo "   ❌ Bridge Server is NOT Running"
    echo "   Last run: Feb 19, 12:36 PM"
fi
echo ""

# Check YFinance Feed
echo "2. YFINANCE FEED STATUS:"
if ps aux | grep rt_yahoo_feed | grep -v grep > /dev/null 2>&1; then
    echo "   ✅ YFinance Feed is RUNNING"
    ps aux | grep rt_yahoo_feed | grep -v grep | awk '{print "   PID:", $2, "  CPU:", $3"%", "  MEM:", $4"%"}'
else
    echo "   ❌ YFinance Feed is NOT Running"
fi
echo ""

# Check MT4 Application
echo "3. MT4 APPLICATION STATUS:"
if pgrep -f "MetaTrader 4.app" > /dev/null 2>&1; then
    echo "   ✅ MT4 Application is RUNNING"
else
    echo "   ❌ MT4 Application is NOT Running"
fi
echo ""

# Check MT4 EAs in Experts Directory
echo "4. MT4 EA FILES:"
MT4_EXPERTS="$HOME/Documents/MQL4/Experts/"
if [ -f "$MT4_EXPERTS/mt4_realtime_executor.mq4" ] && [ -f "$MT4_EXPERTS/mt4_realtime_executor.ex4" ]; then
    echo "   ✅ mt4_realtime_executor.mq4 exists"
    echo "   ✅ mt4_realtime_executor.ex4 exists"
    # Check if compiled
    if [ -f "$MT4_EXPERTS/mt4_realtime_executor.ex4" ]; then
        COMPILED_SIZE=$(wc -c < "$MT4_EXPERTS/mt4_realtime_executor.ex4")
        if [ "$COMPILED_SIZE" -gt 100 ]; then
            echo "   ✅ EA is COMPILED (valid .ex4 file)"
        else
            echo "   ⚠️  EA is NOT compiled properly (file too small)"
        fi
    fi
else
    echo "   ❌ EA file NOT FOUND in $MT4_EXPERTS"
    [ ! -f "$MT4_EXPERTS/mt4_realtime_executor.mq4" ] && echo "      Missing: mt4_realtime_executor.mq4"
    [ ! -f "$MT4_EXPERTS/mt4_realtime_executor.ex4" ] && echo "      Missing: mt4_realtime_executor.ex4"
fi
echo ""

# Check MT4 Journal/Experts Logs
echo "5. MT4 TERMINAL STATUS:"
echo "   Please check MT4 Terminal for:"
echo "   - Experts tab for error messages"
echo "   - Journal tab for log entries"
echo "   - Terminal tab for any alerts or warnings"
echo "   - Status of mt4_realtime_executor EA (should say '0 initialized')"
echo ""

# Check Recent Bridge Log
echo "6. BRIDGE SERVER LOG (last 20 lines):"
if [ -f "$HOME/Documents/logs/mt4_bridge.log" ]; then
    tail -20 "$HOME/Documents/logs/mt4_bridge.log" | sed 's/^/   /'
else
    echo "   ❌ Log file not found"
fi
echo ""

# Check for Recent Orders in MT4
echo "7. ORDER STATUS:"
echo "   Check MT4 Terminal → Account History"
echo "   → Open Trades tab"
echo "   → Look for any active positions"
echo "   If none, verify EA is attached and configured"
echo ""

# Quick Action Recommendations
echo "=== QUICK ACTION RECOMMENDATIONS ==="
echo ""

# Check if EA needs to be attached
if ! pgrep -f "MetaTrader 4.app" > /dev/null 2>&1 || ! [ -f "$MT4_EXPERTS/mt4_realtime_executor.ex4" ]; then
    echo "ACTION 1: If MT4 is not running, open MT4:"
    echo "   open /Applications/MetaTrader\ 4.app"
    echo ""

    echo "ACTION 2: If EA is not attached to chart, attach it:"
    echo "   1. Open MT4 Terminal"
    echo "   2. Open a chart (e.g., BABA or TSLA)"
    echo "   3. Press Ctrl+E (Experts tab)"
    echo "   4. Drag mt4_realtime_executor.ex4 to chart"
    echo "   5. Configure settings in MT4 Terminal → Expert Properties:"
    echo "      - AutoRiskManagement: true"
    echo "      - EnableUnsupervisedLearning: true"
    echo "      - BaseCurrency: USD"
    echo "      - Symbol: BABA (or your chosen stock)"
    echo "      - VolatilityThreshold: 0.02"
    echo "      - RiskPerTrade: 0.02"
    echo "      - RSIOverbought: 70"
    echo "      - RSIOversold: 30"
    echo "      - RSIPeriod: 14"
    echo "      - PollingInterval: 5"
    echo "   6. Enable AutoTrading (F8 → Turn on)"
else
    echo "✅ RECOMMENDATIONS:"
    echo "   1. Ensure MT4 AutoTrading is enabled (F8 → AutoTrading ON)"
    echo "   2. Verify mt4_realtime_executor EA is attached to a chart"
    echo "   3. Check Experts tab for any error messages"
    echo "   4. Monitor for signals: BUY/SELL will appear in terminal output"
    echo "   5. Review logs for any YFinance or socket errors"
fi
echo ""

echo "=== END OF DIAGNOSTIC ==="
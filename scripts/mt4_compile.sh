#!/bin/bash
# MT4 EA Compilation Helper
# MC Jesus (Marcelo Marshall De Siqueira)
# Date: 2026-02-19

echo "=== MT4 EA Compilation Helper ==="
echo ""

# Check if MT4 is running
if ! pgrep -f "MetaTrader 4.app" > /dev/null 2>&1; then
    echo "❌ ERROR: MT4 is not running!"
    echo "   Please start MT4 first:"
    echo "   open /Applications/MetaTrader\ 4.app"
    exit 1
fi

echo "✅ MT4 is running"
echo ""

# Source file
EA_SOURCE="mt4_realtime_executor.mq4"
EA_OUTPUT="mt4_realtime_executor.ex4"
MQL4_FOLDER="$HOME/Documents/MQL4/Experts"

# Check source file
if [ ! -f "$MQL4_FOLDER/$EA_SOURCE" ]; then
    echo "❌ ERROR: Source file not found: $MQL4_FOLDER/$EA_SOURCE"
    exit 1
fi

echo "✅ Source file found: $MQL4_FOLDER/$EA_SOURCE"
echo ""

# Try to compile using Python with MQL4 compiler
echo "Attempting compilation via Python..."
cd "$MQL4_FOLDER"

# Try running MT4 compiler via Wine if available
if command -v wine64 &> /dev/null || command -v wine &> /dev/null; then
    echo "Wine detected, trying MT4 compile..."

    # Detect Wine path and MT4 path
    WINE_PATH=$(which wine64 || which wine || echo "wine")
    MT4_PATH="/Applications/MetaTrader 4.app"

    if [ -d "$MT4_PATH" ]; then
        # Set up environment
        export WINEPREFIX="$HOME/.wine"
        export WINEDEBUG="-all"

        # Navigate to MT4 data folder
        cd "$HOME/Library/Application Support/net.metaquotes.wine.metatrader4/"

        # Try compiling
        "$WINE_PATH" "/Applications/MetaTrader 4.app/Contents/MacOS/mt4_terminal" --build "$EA_SOURCE" 2>&1

        if [ $? -eq 0 ]; then
            echo "✅ Compilation completed!"
        else
            echo "⚠️  Wine compilation had issues"
            echo "   Please compile manually in MT4:"
            echo "   1. Open MT4 Terminal"
            echo "   2. Press F4 to open MetaEditor"
            echo "   3. Open $EA_SOURCE"
            echo "   4. Press F7 to compile"
            echo "   5. Check for errors in Output window"
        fi
    else
        echo "❌ MT4 not found at expected path: $MT4_PATH"
    fi
else
    echo "⚠️  Wine not found"
    echo ""
    echo "MANUAL COMPILATION REQUIRED:"
    echo "==========================="
    echo "1. Open MT4 Terminal"
    echo "2. Press F4 to open MetaEditor"
    echo "3. In MetaEditor, open the file: mt4_realtime_executor.mq4"
    echo "4. Navigate to File → Compile (or press F7)"
    echo "5. Check the Output window for any compilation errors"
    echo "6. If successful, check the Experts folder for mt4_realtime_executor.ex4"
    echo "7. The EA is now ready to attach to a chart"
fi

echo ""
echo "✅ Verification:"
if [ -f "$MQL4_FOLDER/$EA_OUTPUT" ]; then
    echo "   ✅ Compiled EA found: $EA_OUTPUT"
    SIZE=$(ls -lh "$MQL4_FOLDER/$EA_OUTPUT" | awk '{print $5}')
    echo "   Size: $SIZE"
else
    echo "   ⚠️  Compiled EA not yet found (check manually above)"
fi
echo ""

echo "NEXT STEPS:"
echo "==========="
echo "1. Ensure mt4_realtime_executor.ex4 exists in MQL4/Experts/"
echo "2. Open any chart in MT4 (e.g., EURUSD, GBPUSD, or stock chart)"
echo "3. Press Ctrl+E to open Experts tab"
echo "4. Drag mt4_realtime_executor.ex4 to the chart"
echo "5. Configure Expert Properties in MT4:"
echo "   - Symbol: BABA or your target stock"
echo "   - AutoRiskManagement: true"
echo "   - RiskPerTrade: 0.02"
echo "   - PollingInterval: 5"
echo "   - EnableUnsupervisedLearning: true"
echo "6. Enable AutoTrading (F8 → AutoTrading ON)"
echo "7. Monitor Experts tab for signals (BUY/SELL/HOLD)"
echo ""
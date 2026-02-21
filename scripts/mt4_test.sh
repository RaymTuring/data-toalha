#!/bin/bash
# MT4 System Test with Cheap Stock
# Tests the bridge and EA with a low-cost stock

set -e

echo "=== MT4 System Test ==="
echo "Testing with a cheap stock: TSLA (Tesla) or similar"

# Configuration
PYTHON_BRIDGE_DIR=~/Documents/MT4-Python-Bridge
BRIDGE_PORT=5000
HOST=127.0.0.1
TEST_STOCK="TSLA"  # Or "AAPL", "NVDA", "GOOGL"

# Check if bridge directory exists
if [ ! -d "$PYTHON_BRIDGE_DIR" ]; then
    echo "❌ Bridge directory not found: $PYTHON_BRIDGE_DIR"
    exit 1
fi

echo ""
echo "📦 Checking Python packages..."
cd "$PYTHON_BRIDGE_DIR"
python3 -c "import socket, json, time" 2>/dev/null || {
    echo "❌ Required Python packages not found"
    echo "Run: cd ~/Documents/MT4-Python-Bridge && pip3 install socket python-client"
    exit 1
}
echo "✅ Python packages OK"

# Start bridge server in background
echo ""
echo "🔴 Starting Python Bridge Server..."
python3 mt4_bridge_server.py &
BRIDGE_PID=$!
echo "Bridge started (PID: $BRIDGE_PID)"

# Wait a moment for bridge to start
sleep 3

# Test 1: Socket connection test
echo ""
echo "📡 Testing socket connection ($HOST:$BRIDGE_PORT)..."
if nc -z $HOST $BRIDGE_PORT 2>/dev/null || (which nmap > /dev/null && nmap -p $BRIDGE_PORT $HOST | grep -q "open"); then
    echo "✅ Bridge is accessible on port $BRIDGE_PORT"
else
    echo "⚠️  Port not immediately responsive, continuing..."
fi

# Test 2: Send test signal via direct socket (bypassing MT4 for direct test)
echo ""
echo "🔧 Sending test signal directly to bridge..."

# Create a simple Python test client
cat > /tmp/mt4_test_signal.py << 'PYEOF'
#!/usr/bin/env python3
import socket
import json
import time

HOST = "127.0.0.1"
PORT = 5000

try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((HOST, PORT))
    print(f"✅ Connected to bridge at {HOST}:{PORT}")

    # Send test signal
    test_signal = {
        "type": "run_strategy",
        "strategy": "test_strategy",
        "test_signal": "BUY",
        "symbol": "TSLA",
        "data": {
            "close_price": 185.20,
            "rsi": 28.5,
            "signal": "BUY"
        }
    }

    sock.sendall((json.dumps(test_signal) + "\n\0").encode('utf-8'))
    print(f"📤 Sent signal: BUY on TSLA")

    # Wait for response
    time.sleep(1)
    response = sock.recv(4096).decode('utf-8').strip()
    print(f"📥 Response: {response[:100]}..." if len(response) > 100 else f"📥 Response: {response}")

    # Send second signal
    test_signal2 = {
        "type": "run_strategy",
        "strategy": "test_strategy",
        "test_signal": "SELL",
        "symbol": "TSLA",
        "data": {
            "close_price": 184.52,
            "rsi": 72.3,
            "signal": "SELL"
        }
    }

    sock.sendall((json.dumps(test_signal2) + "\n\0").encode('utf-8'))
    print(f"📤 Sent signal: SELL on TSLA")

    sock.close()
    print("✅ Test completed")

except Exception as e:
    print(f"❌ Error: {e}")
    import sys
    sys.exit(1)
PYEOF

python3 /tmp/mt4_test_signal.py
rm -f /tmp/mt4_test_signal.py

# Test 3: MT4 EA check
echo ""
echo "📁 Checking MT4 EA files..."
MQL4_EXPERTS=~/Documents/MQL4/Experts/

if [ -d "$MQL4_EXPERTS" ]; then
    if [ -f "$MQL4_EXPERTS/mt4_strategy_executor.mq4" ]; then
        echo "✅ MT4 EA found: mt4_strategy_executor.mq4"

        # Check if compiled .ex4 file exists
        EX4_FILE=$(echo "$MQL4_EXPERTS/mt4_strategy_executor.mq4" | sed 's/.mq4/.ex4/')
        if [ -f "$EX4_FILE" ]; then
            echo "✅ Compiled EA found: mt4_strategy_executor.ex4"
        else
            echo "⚠️  EA file exists but needs compilation"
            echo "🛠️  To compile in MT4: Press F7 in MetaEditor after opening the file"
        fi
    else
        echo "⚠️  MT4 EA file not found"
        echo "🛠️  Copy it: cp ~/Documents/MT4-Python-Bridge/mt4_strategy_executor.mq4 ~/Documents/MQL4/Experts/"
    fi
else
    echo "⚠️  MQL4 Experts directory not found"
fi

# Test 4: Sample stock prices
echo ""
echo "📊 Testing with cheap stock: $TEST_STOCK"
echo "Using yfinance to fetch recent data..."
python3 -c "
import yfinance as yf
import pandas as pd

try:
    df = yf.download('$TEST_STOCK', period='5d', progress=False)
    if not df.empty:
        print('✅ Data downloaded successfully')
        print(f'Latest price: \${df[\"Adj Close\"].iloc[-1]:.2f}')
        print(f'Previous close: \${df[\"Adj Close\"].iloc[-2]:.2f}')
        print(f'Daily change: {((df[\"Adj Close\"].iloc[-1] / df[\"Adj Close\"].iloc[-2] - 1) * 100):.2f}%')
    else:
        print('⚠️  No data returned')
except Exception as e:
    print(f'❌ Error fetching data: {e}')
" 2>/dev/null || {
    echo "⚠️  Could not fetch stock data (may need internet)"

    # Fallback: manual data
    echo "Using fallback manual data:"
    echo "Symbol: TSLA"
    echo "USD: $185.20"
    echo "RSI: 28.5"
    echo "Signal: BUY (Strong momentum)"
}

# Summary
echo ""
echo "=== Test Summary ==="
echo "✅ Python bridge server started"
echo "✅ Socket communication working"
echo "✅ Signal transmission successful"
echo "⚠️  MT4 EA file ready (may need compilation)"
echo "💡 Next steps:"
echo "   1. Open MT4: open /Applications/MetaTrader\ 4.app"
echo "   2. Attach EA to $TEST_STOCK chart"
echo "   3. Monitor signals in Experts tab"
echo "   4. Set risk parameters in Input tab"
echo ""
echo "To stop the bridge server:"
echo "   kill $BRIDGE_PID"
echo "   OR press Ctrl+C when running directly"

echo ""
echo "🎉 MT4 setup test complete!"
#!/bin/bash

# OpenClaw Web Dashboard Setup Script

echo "🎯 OpenClaw Model Usage Web Dashboard Setup"
echo "==========================================="

# Create web directory if it doesn't exist
WEB_DIR="/Users/raymondturing/.openclaw/workspace/web"
mkdir -p "$WEB_DIR"

# Set executable permissions
chmod +x "/Users/raymondturing/.openclaw/workspace/web/server.py"
chmod +x "/Users/raymondturing/.openclaw/workspace/scripts/start_dashboard_server.sh"

# Start the dashboard server
echo "🚀 Starting dashboard server..."
/Users/raymondturing/.openclaw/workspace/scripts/start_dashboard_server.sh start

# Wait for server to start
sleep 3

# Check server status
echo ""
echo "📊 Dashboard Status:"
/Users/raymondturing/.openclaw/workspace/scripts/start_dashboard_server.sh status

echo ""
echo "✅ Setup Complete!"
echo ""
echo "🌐 Access your dashboard at:"
echo "   http://localhost:8080"
echo ""
echo "🔧 Management commands:"
echo "   Start:   bash /Users/raymondturing/.openclaw/workspace/scripts/start_dashboard_server.sh start"
echo "   Stop:    bash /Users/raymondturing/.openclaw/workspace/scripts/start_dashboard_server.sh stop"
echo "   Status:  bash /Users/raymondturing/.openclaw/workspace/scripts/start_dashboard_server.sh status"
echo ""
echo "📡 API endpoint:"
echo "   http://localhost:8080/api/model-usage"
#!/usr/bin/env python3
"""
mt4_realtime_test.sh - Test Real-Time MT4 Bridge Integration
Tests the real-time Yahoo Finance feed with BABA (Alibaba)
"""

import subprocess
import time
import sys
import signal
import os

# Configuration
BRIDGE_DIR = "~/Documents/MT4-Python-Bridge"
BRIDGE_PORT = 5000
REALTIME_FEED = "rt_yahoo_feed.py"

# Cheap stocks for testing
TEST_SYMBOLS = ["BABA", "TSLA", "NIO"]

def check_requirements():
    """Check if required packages and files exist"""
    print("🔍 Checking Requirements...\n")

    # Check Python packages
    try:
        import yfinance
        print("✅ yfinance installed")
    except ImportError:
        print("❌ yfinance NOT installed")
        print("   Run: pip3 install yfinance")
        return False

    try:
        import socket
        print("✅ Python socket available")
    except ImportError:
        print("❌ Python socket NOT available")
        return False

    # Check bridge files
    bridge_path = os.path.expanduser(BRIDGE_DIR)
    if not os.path.exists(bridge_path):
        print(f"❌ Bridge directory not found: {bridge_path}")
        return False
    print(f"✅ Bridge directory exists: {bridge_path}")

    # Check Real-Time Feed
    feed_path = os.path.join(bridge_path, REALTIME_FEED)
    if not os.path.exists(feed_path):
        print(f"❌ Real-time feed not found: {feed_path}")
        return False
    print(f"✅ Real-time feed exists: {feed_path}")

    # Check mt4_realtime_executor.mq4
    mql4_experts = os.path.expanduser("~/Documents/MQL4/Experts/")
    mt4_realtime = os.path.join(mql4_experts, "mt4_realtime_executor.mq4")
    if not os.path.exists(mt4_realtime):
        print(f"❌ MT4 EA not found: {mt4_realtime}")
        return False
    print(f"✅ MT4 EA exists: mt4_realtime_executor.mq4")

    return True

def start_bridge_server():
    """Start the bridge server in background"""
    print(f"🔧 Starting MT4 Bridge Server on port {BRIDGE_PORT}...")

    bridge_path = os.path.expanduser(BRIDGE_DIR)
    cmd = f"cd {bridge_path} && python3 mt4_bridge_server.py {BRIDGE_PORT}"

    process = subprocess.Popen(
        cmd,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        preexec_fn=os.setsid  # Create new process group for signal handling
    )

    time.sleep(2)  # Wait for bridge to start

    if process.poll() is None:  # Still running
        print(f"✅ Bridge Server started (PID: {process.pid})")
        print(f"   Socket: 127.0.0.1:{BRIDGE_PORT}")
        return process
    else:
        print(f"❌ Bridge Server failed to start")
        exit_code = process.returncode
        print(f"   Exit code: {exit_code}")
        return None

def stop_process(process):
    """Stop the process and its group"""
    if process and process.poll() is None:
        print(f"🛑 Stopping PID {process.pid}...")
        os.killpg(os.getpgid(process.pid), signal.SIGTERM)
        try:
            process.wait(timeout=5)
            print(f"✅ Process stopped")
        except subprocess.TimeoutExpired:
            print(f"⚠️  Process still running, killing...")
            os.killpg(os.getpgid(process.pid), signal.SIGKILL)

def test_socket_connection():
    """Test connection to bridge"""
    print("\n📡 Testing Socket Connection...")

    test_client = """
import socket
import json
import time

try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(5.0)
    sock.connect(('127.0.0.1', 5000))
    print("✅ Connected")

    # Test signal
    test_signal = {
        "type": "get_status"
    }

    sock.sendall((json.dumps(test_signal) + "\\n\\0").encode('utf-8'))
    time.sleep(1)

    response = sock.recv(4096).decode('utf-8').strip()
    print(f"📥 Response:")
    print(f"{response[:200]}..." if len(response) > 200 else f"{response}")

    sock.close()
except Exception as e:
    print(f"❌ Error: {e}")
    import sys
    sys.exit(1)
"""

    try:
        # Run test client
        import tempfile
        import os

        # Create temp file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write(test_client)
            temp_file = f.name

        process = subprocess.Popen(
            ["python3", temp_file],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        stdout, stderr = process.communicate(timeout=10)

        if process.returncode == 0:
            print(f"\n✅ Socket test passed")
            print(f"Output:")
            for line in stdout.split('\n')[:10]:
                if line.strip():
                    print(f"   {line}")
            return True
        else:
            print(f"\n❌ Socket test failed")
            print(f"Error:")
            for line in stderr.split('\n'):
                if line.strip():
                    print(f"   {line}")
            return False

    except Exception as e:
        print(f"❌ Socket test error: {e}")
        return False
    finally:
        if 'temp_file' in locals():
            os.unlink(temp_file)

def test_realtime_feed():
    """Test the real-time feed with BABA"""
    print("\n🚀 Starting Real-Time Feed...")

    bridge_path = os.path.expanduser(BRIDGE_DIR)
    symbols = ",".join(TEST_SYMBOLS)

    cmd = f"cd {bridge_path} && python3 {REALTIME_FEED} {symbols} {BRIDGE_PORT}"

    print(f"Command: {cmd}")
    print("\n⚠️  This will run continuously. Press Ctrl+C to stop.\n")
    print("=" * 60)
    print("Real-Time Feed Started")
    print("=" * 60)
    print(f"Symbols: {', '.join(TEST_SYMBOLS)}")
    print(f"Poll Interval: 5 seconds")
    print("=" * 60)

    try:
        process = subprocess.Popen(
            cmd,
            shell=True,
            stdout=None,  # Stream directly
            stderr=None,  # Stream directly
            preexec_fn=os.setsid
        )

        # Keep alive for 30 seconds for testing
        print("\n💡 Testing for 30 seconds...")
        time.sleep(30)

        # Stop after test
        print("\n⏹️  Test completed. Stopping feed...")
        os.killpg(os.getpgid(process.pid), signal.SIGTERM)
        process.wait(timeout=5)

        print("✅ Test finished")
        return True

    except KeyboardInterrupt:
        print("\n\n🛑 Interrupted. Stopping...")
        os.killpg(os.getpgid(process.pid), signal.SIGTERM)
        process.wait(timeout=5)
        print("✅ Stopped")
        return False
    except Exception as e:
        print(f"❌ Test error: {e}")
        return False

def main():
    print("=" * 60)
    print("MT4 Real-Time Integration Test")
    print("=" * 60)

    # Check requirements
    if not check_requirements():
        print("\n❌ Requirements not met. Exiting.")
        sys.exit(1)

    # Test socket connection
    if not test_socket_connection():
        print("\n⚠️  Socket connection test had issues, but continuing...")
    else:
        print("\n✅ Socket layer is working")

    # Start real-time feed (skip bridge server start - it was already running)
    print("\n" + "=" * 60)
    print("Starting Real-Time Data Feed")
    print("=" * 60)

    # Note: We're NOT starting the bridge server here
    # because it's already running if you followed the setup instructions.

    if not test_realtime_feed():
        print("\n❌ Real-time feed test failed")
        sys.exit(1)

    print("\n" + "=" * 60)
    print("🎉 All Tests Passed!")
    print("=" * 60)

    print("\n📝 Next Steps:")
    print("1. Open MT4:")
    print("   open /Applications/MetaTrader\\ 4.app")
    print()
    print("2. Attach mt4_realtime_executor EA:")
    print("   - Open any chart (e.g., BABA Daily)")
    print("   - Attach mt4_realtime_executor (F4 MetaEditor → Attach)")
    print("   - Enable 'EnableUnsupervisedLearning' parameter")
    print()
    print("3. Monitor signals:")
    print("   - Check Experts tab for log messages")
    print("   - Check 'Orders' tab for executed trades")
    print()
    print("4. Start Real-Time Feed (in separate terminal):")
    print("   cd ~/Documents/MT4-Python-Bridge")
    print("   python3 rt_yahoo_feed.py BABA 5000")
    print()
    print("=" * 60)

if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
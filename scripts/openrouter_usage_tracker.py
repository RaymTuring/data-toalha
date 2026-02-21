#!/usr/bin/env python3

import os
import sys
import json
import logging
from datetime import datetime, timedelta
import requests

# Configure logging
logging.basicConfig(
    filename='/Users/raymondturing/.openclaw/logs/model_usage_tracking.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def load_config(config_path):
    """Load configuration from JSON file."""
    try:
        with open(config_path, 'r') as f:
            return json.load(f)
    except (IOError, json.JSONDecodeError) as e:
        logging.error(f"Error loading config: {e}")
        return None

def fetch_openrouter_usage(api_key, hours_back=24):
    """Fetch usage data from OpenRouter API."""
    if not api_key:
        logging.error("No API key provided")
        return None

    # Calculate timestamp for 24 hours ago
    end_time = datetime.utcnow()
    start_time = end_time - timedelta(hours=hours_back)
    
    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json'
    }
    
    params = {
        'start_time': start_time.isoformat() + 'Z',
        'end_time': end_time.isoformat() + 'Z'
    }
    
    try:
        response = requests.get(
            'https://openrouter.ai/api/v1/usage', 
            headers=headers, 
            params=params
        )
        response.raise_for_status()
        usage_data = response.json()
        
        # Log successful API call
        logging.info(f"Successfully fetched usage data: {usage_data}")
        return usage_data
    except requests.RequestException as e:
        logging.error(f"Error fetching usage: {e}")
        return None

def calculate_cost(input_tokens, output_tokens, cost_per_million):
    """Calculate estimated cost based on token usage."""
    total_tokens = input_tokens + output_tokens
    return (total_tokens / 1_000_000) * cost_per_million

def update_dashboard(agent_name, usage_data, dashboard_path, cost_per_million):
    """Update the dashboard markdown file with latest usage information."""
    try:
        # Extract token information
        input_tokens = usage_data.get('total_tokens_input', 0)
        output_tokens = usage_data.get('total_tokens_output', 0)
        
        # Calculate cost
        estimated_cost = calculate_cost(input_tokens, output_tokens, cost_per_million)
        
        # Get current model (use a default if not available)
        current_model = usage_data.get('model', 'Unknown Model')
        
        # Current timestamp
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        # Read existing dashboard content
        with open(dashboard_path, 'r') as f:
            lines = f.readlines()
        
        # Update the specific agent's line
        for i, line in enumerate(lines):
            if f"| {agent_name} |" in line:
                lines[i] = f"| {agent_name} | {current_model} | {timestamp} | {input_tokens} | {output_tokens} | ${estimated_cost:.4f} | Available |\n"
                break
        
        # Write updated content back to file
        with open(dashboard_path, 'w') as f:
            f.writelines(lines)
        
        logging.info(f"Updated dashboard for {agent_name}")
    except Exception as e:
        logging.error(f"Error updating dashboard: {e}")

def main():
    # Paths
    config_path = '/Users/raymondturing/.openclaw/workspace/configs/openrouter_tracking.json'
    dashboard_path = '/Users/raymondturing/.openclaw/workspace/MODEL_USAGE_DASHBOARD.md'
    
    # Load configuration
    config = load_config(config_path)
    if not config:
        logging.error("Could not load configuration")
        sys.exit(1)
    
    # Cost per million tokens
    cost_per_million = config['tracking_config']['cost_per_million_tokens']
    
    # Iterate through bots
    for bot in config['bots']:
        # Fetch environment variable for API key
        api_key_var = bot['api_key'].replace('${', '').replace('}', '')
        api_key = os.environ.get(api_key_var)
        
        if not api_key:
            logging.warning(f"No API key found for {bot['name']}")
            continue
        
        # Fetch usage data
        usage_data = fetch_openrouter_usage(api_key, config['tracking_config']['lookback_hours'])
        
        if usage_data:
            # Update dashboard
            update_dashboard(bot['name'], usage_data, dashboard_path, cost_per_million)
        else:
            logging.warning(f"Could not fetch usage for {bot['name']}")

if __name__ == '__main__':
    main()
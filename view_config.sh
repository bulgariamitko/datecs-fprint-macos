#!/bin/bash

CONFIG_FILE="$HOME/Documents/DatecsFPrint.config"

echo "=== Datecs FPrint Configuration ==="

if [ -f "$CONFIG_FILE" ]; then
    echo "Configuration file found at: $CONFIG_FILE"
    echo ""
    echo "Current settings:"
    echo "=================="

    # Pretty print JSON if jq is available
    if command -v jq &> /dev/null; then
        jq . "$CONFIG_FILE"
    else
        # Fallback to basic cat
        cat "$CONFIG_FILE"
    fi
else
    echo "No configuration file found."
    echo "The app will show first-time setup on next launch."
    echo ""
    echo "To manually create config, copy example_config.json to:"
    echo "$CONFIG_FILE"
fi

echo ""
echo "=== Testing Directory Structure ==="
FPRINT_DIR="$HOME/Desktop/FPrint"
if [ -d "$FPRINT_DIR" ]; then
    echo "✓ FPrint directory exists: $FPRINT_DIR"
    echo "Contents:"
    ls -la "$FPRINT_DIR"
else
    echo "ℹ️  FPrint directory will be created on first use"
fi
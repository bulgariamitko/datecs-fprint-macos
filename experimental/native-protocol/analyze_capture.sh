#!/bin/bash

CAPTURE_FILE="/tmp/datecs_capture_20251027_161415.pcap"
OUTPUT_FILE="/tmp/capture_analysis.txt"

echo "Analyzing capture file..."
echo "This will extract the hex data from the printer communication"
echo ""

# Extract TCP payload data
sudo tshark -r "$CAPTURE_FILE" -T fields -e tcp.payload 2>/dev/null | grep -v "^$" > "$OUTPUT_FILE"

# Make output readable by user
sudo chmod 644 "$OUTPUT_FILE"

echo "Analysis saved to: $OUTPUT_FILE"
echo ""
echo "Contents:"
cat "$OUTPUT_FILE"

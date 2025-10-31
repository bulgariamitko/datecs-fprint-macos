#!/bin/bash

CAPTURE_FILE="/tmp/macos_print_capture.pcap"

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║          CAPTURE macOS PRINTING TO ANALYZE                         ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

# Start capture in background
echo "Starting packet capture..."
echo '1718' | sudo -S tshark -i utun4 -f "host 192.168.1.155 and port 4999" -w "$CAPTURE_FILE" -P &
TSHARK_PID=$!

sleep 2
echo "✓ Capture started (PID: $TSHARK_PID)"
echo ""

# Send test commands
echo "Sending test commands to printer..."
echo ""
node send_test_print.js

echo ""
echo "Waiting for capture to finish..."
sleep 2

# Stop capture
echo ""
echo "Stopping capture..."
echo '1718' | sudo -S kill $TSHARK_PID 2>/dev/null
sleep 1

# Make file readable
echo '1718' | sudo -S chmod 644 "$CAPTURE_FILE"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Capture complete!"
echo "File: $CAPTURE_FILE"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Analyze
echo "Extracting hex data..."
tshark -r "$CAPTURE_FILE" -T fields -e data.data 2>/dev/null | while read line; do
    echo "$line" | xxd -r -p | hexdump -C
done

echo ""
echo "Done!"

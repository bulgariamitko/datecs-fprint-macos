#!/bin/bash

# Wireshark Capture Script for Datecs Printer Traffic
# This will capture all traffic between your Mac and the printer

PRINTER_IP="192.168.1.155"
PRINTER_PORT="4999"
CAPTURE_FILE="/tmp/datecs_capture_$(date +%Y%m%d_%H%M%S).pcap"

# Detect which interface routes to the printer
INTERFACE=$(route get "$PRINTER_IP" 2>/dev/null | grep interface | awk '{print $2}')
if [ -z "$INTERFACE" ]; then
    INTERFACE="en0"
fi

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║          WIRESHARK CAPTURE - DATECS PRINTER                        ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Settings:"
echo "  Printer IP: $PRINTER_IP"
echo "  Port: $PRINTER_PORT"
echo "  Interface: $INTERFACE (auto-detected)"
echo "  Capture file: $CAPTURE_FILE"
echo ""
echo "Starting capture..."
echo "Press Ctrl+C to stop capturing"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Start tshark capture
sudo tshark -i "$INTERFACE" -f "host $PRINTER_IP and port $PRINTER_PORT" -w "$CAPTURE_FILE" -P

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Capture stopped!"
echo "File saved to: $CAPTURE_FILE"
echo ""
echo "To analyze the capture:"
echo "  tshark -r $CAPTURE_FILE -V"
echo ""
echo "Or open in Wireshark GUI:"
echo "  open $CAPTURE_FILE"
echo ""

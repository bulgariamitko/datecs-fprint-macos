#!/usr/bin/env python3
"""
Simple Python script to test TCP communication with Datecs fiscal printers
Use this to verify your printer connection before using the full macOS app
"""

import socket
import time
import sys

def test_datecs_connection(host="192.168.1.1", port=4999):
    """Test connection to Datecs printer"""

    print(f"Testing connection to {host}:{port}...")

    try:
        # Create socket connection
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)

        # Connect to printer
        sock.connect((host, port))
        print("✓ TCP connection established")

        # Test command: Get device information
        test_command = "I,1,______,_,__;0;80"
        print(f"Sending command: {test_command}")

        # Send command with CR+LF terminator
        sock.send((test_command + "\r\n").encode('utf-8'))

        # Receive response
        response = sock.recv(1024).decode('utf-8').strip()
        print(f"Response: {response}")

        # Close connection
        sock.close()
        print("✓ Connection test completed successfully")

        # Parse response
        if response:
            parts = response.split(';')
            if len(parts) > 1:
                print("\nDevice Information:")
                print(f"  Command: {parts[0]}")
                if len(parts) > 1:
                    print(f"  Status: {parts[1]}")
                if len(parts) > 2:
                    print(f"  Version: {parts[2]}")

        return True

    except socket.timeout:
        print("✗ Connection timeout - check IP address and port")
        return False
    except ConnectionRefusedError:
        print("✗ Connection refused - check if printer is powered on and accessible")
        return False
    except Exception as e:
        print(f"✗ Error: {e}")
        return False

def send_command(host, port, command):
    """Send a single command to the printer"""

    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        sock.connect((host, port))

        print(f"Sending: {command}")
        sock.send((command + "\r\n").encode('utf-8'))

        response = sock.recv(1024).decode('utf-8').strip()
        print(f"Response: {response}")

        sock.close()
        return response

    except Exception as e:
        print(f"Error sending command: {e}")
        return None

def main():
    # Default values - change these to match your printer
    host = "192.168.1.1"  # Replace with your printer's IP
    port = 4999           # Standard Datecs TCP port

    if len(sys.argv) > 1:
        host = sys.argv[1]
    if len(sys.argv) > 2:
        port = int(sys.argv[2])

    print("Datecs Printer TCP Test")
    print("=" * 40)

    # Test basic connection
    if not test_datecs_connection(host, port):
        sys.exit(1)

    print("\n" + "=" * 40)
    print("Additional test commands:")

    # Test additional commands
    commands = [
        "N,1,______,_,__;",  # Get last document number
    ]

    for cmd in commands:
        print(f"\nTesting: {cmd}")
        response = send_command(host, port, cmd)
        time.sleep(0.5)  # Small delay between commands

if __name__ == "__main__":
    main()
# Windows Wireshark Capture Instructions for Datecs Printer

## Goal
Capture the exact network traffic between FPrintWIN.exe and the Datecs DP-25MX printer to understand the protocol.

## What You Need
- Windows PC with FPrintWIN.exe working
- Datecs DP-25MX printer at IP: 192.168.1.155:4999
- 10 minutes of time

---

## Step 1: Install Wireshark

1. Download Wireshark for Windows:
   - Go to: https://www.wireshark.org/download.html
   - Download "Windows x64 Installer"
   - Run the installer
   - Install with default options (include "Npcap" when asked)

2. Restart your computer after installation (Npcap requires it)

---

## Step 2: Start Packet Capture

1. **Open Wireshark** (Run as Administrator for best results)

2. **Select your network adapter:**
   - Look for your active network adapter (usually "Wi-Fi" or "Ethernet")
   - It will have a wave graph showing activity
   - Double-click it to start capturing

3. **Apply a filter:**
   - In the filter bar at the top, type: `tcp.port == 4999`
   - Press Enter
   - You should now see only traffic to/from the printer

---

## Step 3: Print a Test Receipt

1. **Open FPrintWIN.exe**

2. **Print a simple non-fiscal receipt:**
   - Create a text file: `C:\temp\test_capture.txt`
   - Put this content in it:
     ```
     Y,1,______,_,__;
     P,1,______,_,__;=== WIRESHARK TEST ===;;;;;
     P,1,______,_,__;Line 1;;;;;
     P,1,______,_,__;Line 2;;;;;
     P,1,______,_,__;Line 3;;;;;
     T,1,______,_,__;
     ```

3. **Execute the file using FPrintWIN:**
   - Configure FPrintWIN to connect to: 192.168.1.155:4999
   - Execute the test_capture.txt file
   - The printer should print a receipt

4. **You should see packets in Wireshark!**
   - Green/blue/black lines appearing
   - Each line is a packet sent to/from the printer

---

## Step 4: Stop and Save Capture

1. **Stop the capture:**
   - Click the red square button (Stop) in Wireshark toolbar
   - Or press: Ctrl+E

2. **Save the capture file:**
   - File → Save As
   - Save to: `C:\temp\printer_capture.pcapng`
   - Format: "Wireshark/tcpdump/... - pcapng"
   - Click Save

---

## Step 5: Export Packet Details

Now we need to export the actual bytes that were sent. This is the CRITICAL part!

### Option A: Export as Text (Easiest)

1. In Wireshark, make sure filter is still `tcp.port == 4999`

2. **Find packets sent TO the printer:**
   - Look for packets with Destination: 192.168.1.155
   - These are the commands Windows is sending

3. **For EACH packet sent to printer:**
   - Click on the packet (it will highlight)
   - Right-click → Copy → ...as a Hex Stream
   - Paste into a text file: `C:\temp\packet_details.txt`
   - Add a note like: "Packet 1 - Length: XX bytes"

### Option B: Export as CSV (More Complete)

1. File → Export Packet Dissections → As CSV
2. Save as: `C:\temp\packets.csv`
3. This gives us all packet details in spreadsheet format

### Option C: Screenshots (Visual Backup)

1. For 2-3 packets sent TO the printer:
   - Click on the packet
   - Expand these sections in the packet details pane:
     - "Ethernet II"
     - "Internet Protocol"
     - "Transmission Control Protocol"
     - "Data" (this is the actual command!)
   - Take a screenshot showing the hex dump at the bottom
   - Save as: `packet1.png`, `packet2.png`, etc.

---

## Step 6: What to Send Back

Create a folder: `C:\temp\wireshark_capture\` with these files:

### Required Files:
1. **`printer_capture.pcapng`** - The full capture file
2. **`packet_details.txt`** - Copy of hex data from key packets
3. **`test_capture.txt`** - The command file you used

### Helpful Additional Files:
4. **Screenshots** - Visual proof of packet structure
5. **`packets.csv`** - Spreadsheet export (if you did Option B)
6. **`notes.txt`** - Any observations you noticed

### In notes.txt, please include:
```
Printer Model: Datecs DP-25MX
Serial Number: DA020990
Printer IP: 192.168.1.155
Printer Port: 4999
FPrintWIN Version: (check Help → About)
Windows Version: (e.g., Windows 10, Windows 11)
Did receipt print successfully? (Yes/No)
Number of packets captured: (look at bottom right of Wireshark)
Any error messages: (if any)
```

---

## Step 7: Transfer Files to Mac Developer

Zip the `C:\temp\wireshark_capture\` folder and send it via:
- Email
- Dropbox/Google Drive
- USB drive
- Any file transfer method

---

## What We're Looking For

The Mac developer needs to see:
1. **The exact bytes** FPrintWIN.exe sends to the printer
2. **The protocol structure** - how commands are framed
3. **The difference** between what Windows sends vs. what we're sending

Specifically looking for:
- Do commands have framing bytes? (like 0x01 at start, 0x03 at end?)
- Is there a checksum? What's the format?
- Are text commands converted to something else?
- Is there an initialization sequence?

---

## Troubleshooting

### "I don't see any packets!"
- Make sure filter is: `tcp.port == 4999`
- Check you're capturing on the right network adapter
- Try: Capture → Refresh Interfaces
- Make sure FPrintWIN is connecting to 192.168.1.155 (not localhost)

### "Wireshark won't start capturing"
- Run Wireshark as Administrator
- Restart computer if you just installed it
- Check Npcap is installed: Control Panel → Programs

### "Too many packets!"
- That's OK! The filter will show only printer traffic
- Just make sure `tcp.port == 4999` is applied

### "Printer didn't print"
- That's OK! We still need the capture
- Note in notes.txt that it failed
- We can see what was sent anyway

---

## Quick Alternative: Use Command Line

If Wireshark GUI is confusing, use command line:

```cmd
cd "C:\Program Files\Wireshark"
tshark.exe -i "Wi-Fi" -f "tcp port 4999" -w C:\temp\capture.pcapng
```

Then:
1. Run FPrintWIN and print
2. Press Ctrl+C to stop
3. Send C:\temp\capture.pcapng

---

## Expected Result

A successful capture will show:
- 3-10 packets total
- SYN/ACK packets (TCP handshake)
- DATA packets (the actual commands)
- FIN packets (connection close)

The DATA packets are what we need - they contain the printer commands!

---

## Questions?

If anything is unclear:
1. Take screenshots of where you're stuck
2. Include error messages
3. Send whatever you captured (even if incomplete)

**Even a partial capture is helpful!**

---

*Created: 2025-10-24*
*For: Datecs DP-25MX macOS Integration Project*

# DatecsFPrint for macOS

[![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://www.apple.com/macos/)
[![Wine](https://img.shields.io/badge/Wine-8.0+-red.svg)](https://www.winehq.org/)
[![Status](https://img.shields.io/badge/Status-In%20Development-yellow.svg)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Use Windows **FPrint.exe** on macOS with **Wine** for Datecs fiscal printers. This repository provides setup instructions and experimental work toward a native macOS solution.

---

## ⚠️ **IMPORTANT: Current Status**

### What Works ✅
- **Wine + FPrint.exe**: You can run Windows FPrint on macOS using Wine (see instructions below)
- **Resident Mode**: File-based command processing works via Wine
- **Full Compatibility**: 100% of FPrint features available through Wine

### What's Under Development 🚧
- **Electron UI**: The Electron + React interface is **NOT functional yet**
- **Wine Integration**: Automatic Wine/FPrint management is **NOT implemented**
- **Native Protocol**: Protocol decoding is incomplete (experimental work in progress)

### What You Should Use Right Now 👉
**Use Wine to run FPrint.exe directly** (skip the Electron app) - see [Quick Start](#-quick-start-using-wine--fprintexe) below.

---

## 🎯 Project Goals

This project has two tracks:

### 1. Wine-based Solution (Working Now)
Run Windows FPrint.exe on macOS using Wine for immediate functionality.

### 2. Native macOS Solution (Future Goal)
- Electron + React UI for configuration and monitoring
- Native protocol implementation (no Wine needed)
- **Status**: Under development, not ready for use

---

## 🚀 Quick Start (Using Wine + FPrint.exe)

This is the **recommended approach** that actually works right now.

### Step 1: Install Wine

```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Wine
brew install wine-stable

# Verify installation
wine --version
# Should show: wine-8.0 or newer
```

### Step 2: Install FPrint.exe

You need the Windows FPrint software from Datecs.

#### Option A: Run Installer with Wine
```bash
# Download FPrint installer from Datecs
# Then run:
wine FPrintSetup.exe

# Follow the installation wizard
# Default path: C:\Program Files\Datecs\FPrint\
```

#### Option B: Manual Installation
```bash
# Create directory
mkdir -p ~/.wine/drive_c/Program\ Files/Datecs/FPrint/

# Copy FPrint files
cp /path/to/FPrint.exe ~/.wine/drive_c/Program\ Files/Datecs/FPrint/
cp /path/to/*.dll ~/.wine/drive_c/Program\ Files/Datecs/FPrint/

# Verify
ls ~/.wine/drive_c/Program\ Files/Datecs/FPrint/FPrint.exe
```

#### Option C: Extract from Installer
```bash
# Install p7zip
brew install p7zip

# Extract installer
7z x FPrintSetup.exe -o/tmp/fprint_extracted

# Copy to Wine directory
mkdir -p ~/.wine/drive_c/Program\ Files/Datecs/FPrint/
cp /tmp/fprint_extracted/* ~/.wine/drive_c/Program\ Files/Datecs/FPrint/
```

### Step 3: Configure FPrint

Create the configuration file for your printer:

```bash
# Edit the config file
nano ~/.wine/drive_c/Program\ Files/Datecs/FPrint/DatecsFPrint.config
```

**Example configuration:**
```xml
<?xml version="1.0"?>
<configuration>
  <appSettings>
    <add key="IPAddress" value="192.168.1.155" />
    <add key="Port" value="4999" />
    <add key="DeviceModel" value="DP-25MX" />
    <add key="SerialNumber" value="DA020990" />
    <add key="FiscalMemoryNumber" value="12345678" />
    <add key="Timeout" value="10000" />
    <add key="ExecutionFolder" value="C:\FPrintCommands" />
  </appSettings>
</configuration>
```

**Adjust these values for your printer:**
- `IPAddress` - Your printer's IP (check printer display/menu)
- `Port` - Usually 4999 for Datecs
- `DeviceModel` - Your printer model (DP-25MX, DP-50X, FP-2000, etc.)
- `SerialNumber` - From printer info menu
- `FiscalMemoryNumber` - From printer info menu
- `ExecutionFolder` - Where to watch for command files

### Step 4: Create Command Folders

```bash
# Create command and result folders
mkdir -p ~/.wine/drive_c/FPrintCommands
mkdir -p ~/.wine/drive_c/FPrintResults
```

### Step 5: Run FPrint in Resident Mode

```bash
# Start FPrint
wine ~/.wine/drive_c/Program\ Files/Datecs/FPrint/FPrint.exe /resident

# FPrint will now monitor C:\FPrintCommands for command files
```

**To run in background:**
```bash
# Start FPrint in background
nohup wine ~/.wine/drive_c/Program\ Files/Datecs/FPrint/FPrint.exe /resident > /tmp/fprint.log 2>&1 &

# Check if running
ps aux | grep FPrint.exe

# View logs
tail -f /tmp/fprint.log
```

### Step 6: Send Test Command

```bash
# Create a test command file
echo "I,1,______,_,__;0;80" > ~/.wine/drive_c/FPrintCommands/test01.txt

# Wait a moment, then check result
cat ~/.wine/drive_c/FPrintResults/test01.txt
```

If you see a response with printer information, it's working! 🎉

---

## 📖 Using FPrint via Wine

### Starting FPrint
```bash
# Foreground (see output)
wine ~/.wine/drive_c/Program\ Files/Datecs/FPrint/FPrint.exe /resident

# Background
nohup wine ~/.wine/drive_c/Program\ Files/Datecs/FPrint/FPrint.exe /resident > /tmp/fprint.log 2>&1 &
```

### Stopping FPrint
```bash
# Find and kill the process
pkill -f FPrint.exe

# Or find PID first
ps aux | grep FPrint.exe
kill <PID>
```

### Sending Commands

FPrint works by monitoring a folder for command files. To send commands:

1. **Create a command file** in the ExecutionFolder:
   ```bash
   # Example: Get device info
   echo "I,1,______,_,__;0;80" > ~/.wine/drive_c/FPrintCommands/cmd001.txt
   ```

2. **FPrint processes it automatically** and creates a result file

3. **Read the result**:
   ```bash
   cat ~/.wine/drive_c/FPrintResults/cmd001.txt
   ```

### Common Commands

```bash
# Get device information
echo "I,1,______,_,__;0;80" > ~/.wine/drive_c/FPrintCommands/info.txt

# Get last document number
echo "N,1,______,_,__;" > ~/.wine/drive_c/FPrintCommands/lastdoc.txt

# Open fiscal receipt
echo "48,1,______,_,__;1;1;1;0;OPERATOR001;" > ~/.wine/drive_c/FPrintCommands/open.txt

# Print text line
echo "54,1,______,_,__;Test Receipt;" > ~/.wine/drive_c/FPrintCommands/print.txt

# Close fiscal receipt
echo "56,1,______,_,__;" > ~/.wine/drive_c/FPrintCommands/close.txt
```

### Automation Script

Create a helper script to send commands easily:

```bash
#!/bin/bash
# save as: fprint-send.sh

COMMAND_DIR="$HOME/.wine/drive_c/FPrintCommands"
RESULT_DIR="$HOME/.wine/drive_c/FPrintResults"

# Generate unique filename
FILENAME="cmd_$(date +%s).txt"

# Write command
echo "$1" > "$COMMAND_DIR/$FILENAME"

# Wait for result
sleep 1

# Show result
if [ -f "$RESULT_DIR/$FILENAME" ]; then
    cat "$RESULT_DIR/$FILENAME"
else
    echo "No result yet, check manually in $RESULT_DIR/$FILENAME"
fi
```

**Usage:**
```bash
chmod +x fprint-send.sh
./fprint-send.sh "I,1,______,_,__;0;80"
```

---

## 🔧 Troubleshooting

### Wine Issues

**Wine not found:**
```bash
# Check installation
which wine
wine --version

# Reinstall if needed
brew reinstall wine-stable
```

**Wine configuration:**
```bash
# Open Wine configuration
winecfg

# Set Windows version to Windows 10
# Check drive mappings (C: should exist)
```

### FPrint Issues

**FPrint won't start:**
```bash
# Check for missing DLL errors
wine ~/.wine/drive_c/Program\ Files/Datecs/FPrint/FPrint.exe

# Install dependencies if needed
brew install winetricks
winetricks dotnet40
winetricks vcrun2019
```

**FPrint not processing files:**
- Verify ExecutionFolder in config matches created folder
- Check file permissions (should be readable/writable)
- Check FPrint logs (if any) in FPrint directory
- Ensure FPrint is actually running: `ps aux | grep FPrint`

### Printer Issues

**Can't connect to printer:**
```bash
# Test network connection
nc -zv YOUR_PRINTER_IP 4999

# Or use telnet
telnet YOUR_PRINTER_IP 4999
```

**Connection works but no response:**
- Verify IP in config matches actual printer IP
- Check printer is powered on and in fiscal mode
- Verify printer network settings
- Check firewall (both macOS and printer)
- Confirm port 4999 is correct for your model

---

## 📁 File Locations Reference

| What | Location |
|------|----------|
| Wine C: drive | `~/.wine/drive_c/` |
| FPrint.exe | `~/.wine/drive_c/Program Files/Datecs/FPrint/FPrint.exe` |
| FPrint config | `~/.wine/drive_c/Program Files/Datecs/FPrint/DatecsFPrint.config` |
| Command files | `~/.wine/drive_c/FPrintCommands/` |
| Result files | `~/.wine/drive_c/FPrintResults/` |
| FPrint logs | `/tmp/fprint.log` (if using nohup) |

---

## 📦 Supported Datecs Printers

All Datecs fiscal printers supported by Windows FPrint work via Wine:

| Model Series | Status | Notes |
|--------------|--------|-------|
| **DP-25MX** | ✅ Tested | Fully working via Wine |
| **DP-50X** | ✅ Compatible | Should work (untested) |
| **FP-2000** | ✅ Compatible | Should work (untested) |
| **All Models** | ✅ Compatible | If Windows FPrint supports it |

---

## 🔮 Future Development

### Electron + React UI (In Progress)

We're working on a modern macOS app with:
- Configuration interface
- Resident mode monitoring
- Activity logging
- Automatic Wine/FPrint management

**Status**: Under development, not functional yet.

**ETA**: Unknown - contributions welcome!

### Native Protocol Implementation (Experimental)

Long-term goal: eliminate Wine dependency with native protocol implementation.

📁 **See [experimental/native-protocol/](experimental/native-protocol/)** for:
- Protocol decoding work
- Test scripts
- Contribution guide

**Status**: Experimental, incomplete. Wine is still required.

---

## 📚 Documentation

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Detailed Wine setup instructions
- **[docs/](docs/)** - Technical protocol documentation
- **[experimental/native-protocol/](experimental/native-protocol/)** - Protocol research
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute

---

## 🤝 Contributing

We welcome contributions in several areas:

### 1. Documentation
- Improve Wine setup instructions
- Add troubleshooting tips
- Create video tutorials

### 2. Electron UI Development
- Help build the configuration interface
- Implement Wine process management
- Create monitoring UI

### 3. Protocol Research
- Decode Datecs commands
- Test with different printer models
- Document findings

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Datecs** for their fiscal printers and FPrint software
- **Wine** project for enabling Windows software on macOS
- **Community** for testing and contributions

---

## 📞 Support

- **Issues**: [GitHub Issues](../../issues) for bugs and problems
- **Discussions**: [GitHub Discussions](../../discussions) for questions
- **Wine Help**: [WineHQ Forums](https://forum.winehq.org/)
- **Datecs Support**: Contact Datecs for printer-specific issues

---

## 🎯 TL;DR - Just Want to Print?

```bash
# 1. Install Wine
brew install wine-stable

# 2. Install FPrint.exe (get from Datecs)
wine FPrintSetup.exe

# 3. Configure printer settings
nano ~/.wine/drive_c/Program\ Files/Datecs/FPrint/DatecsFPrint.config

# 4. Create folders
mkdir -p ~/.wine/drive_c/FPrintCommands ~/.wine/drive_c/FPrintResults

# 5. Start FPrint
wine ~/.wine/drive_c/Program\ Files/Datecs/FPrint/FPrint.exe /resident

# 6. Send test command
echo "I,1,______,_,__;0;80" > ~/.wine/drive_c/FPrintCommands/test.txt

# 7. Check result
cat ~/.wine/drive_c/FPrintResults/test.txt
```

**That's it!** You're now using FPrint on macOS. 🎉

---

**Questions? Problems?** [Open an issue](../../issues) and we'll help!

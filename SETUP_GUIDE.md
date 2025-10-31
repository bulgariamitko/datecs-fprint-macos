# DatecsFPrint for macOS - Setup Guide

Complete guide to setting up Windows FPrint on macOS using Wine.

## Overview

This application uses **Wine** to run the native Windows `FPrint.exe` on macOS, providing 100% compatibility with all Datecs printer features. The Electron + React UI provides a modern interface for configuration and monitoring.

## Prerequisites

### 1. System Requirements
- **macOS 14.0+** (Sonoma or later recommended)
- **Node.js 14+** (for building/running the Electron app)
- **Homebrew** (package manager for macOS)
- At least **2GB free disk space** (for Wine and dependencies)

### 2. Datecs Fiscal Printer
- Network-connected Datecs fiscal printer (TCP/IP)
- Printer IP address
- Printer port (usually 4999)
- Printer model, serial number, and fiscal memory number

## Step-by-Step Installation

### Step 1: Install Wine

Wine is required to run the Windows FPrint.exe on macOS.

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Wine
brew install wine-stable

# Verify Wine installation
wine --version
# Should show: wine-8.0 or newer
```

**Alternative Wine installation methods:**
- Download from [WineHQ](https://www.winehq.org/)
- Use CrossOver (commercial Wine wrapper with GUI)

### Step 2: FPrint Software (Already Included!)

**Good news:** FPrint software is already included in this repository in the `FPrintWIN/` folder!

No need to download or install anything separately. The folder contains:
- `FPrint_SettingsManager.exe` - GUI configuration tool
- `FPrint.exe` - Main printer service
- All required DLLs and support files

### Step 3: Configure FPrint Using Settings Manager

**IMPORTANT:** Use the Settings Manager GUI to configure your printer. This is much easier than editing config files manually.

```bash
# Clone this repository if you haven't
git clone https://github.com/bulgariamitko/datecs-fprint-macos.git
cd datecs-fprint-macos

# Run FPrint Settings Manager
wine FPrintWIN/FPrint_SettingsManager.exe
```

**In the Settings Manager window:**

1. **General Tab:**
   - Enter your printer's **IP Address** (e.g., `192.168.1.155`)
   - Enter **Port** (usually `4999`)
   - Enter **Device Model** (e.g., `DP-25MX`, `DP-50X`, `FP-2000`)
   - Enter **Serial Number** (from printer's info menu)
   - Enter **Fiscal Memory Number** (from printer's info menu)
   - Set **Timeout** (default: `10000` ms)

2. **Resident Mode Tab:**
   - Set **Execution Folder**: `C:\FPrintCommands`
   - This is where FPrint will watch for command files

3. **Click "Save"** to save your configuration

4. **Close** the Settings Manager

The configuration is saved to `FPrintWIN/FPrint.ini` and `FPrintWIN/Settings.dat`.

### Step 4: Create Command/Result Folders

FPrint uses folders to watch for command files (resident mode).

```bash
# Create directories inside Wine's C: drive
mkdir -p ~/.wine/drive_c/FPrintCommands
mkdir -p ~/.wine/drive_c/FPrintResults

# Or create them in your home directory and use symlinks
mkdir -p ~/.datecs-fprint/commands
mkdir -p ~/.datecs-fprint/results
```

### Step 5: Run FPrint in Resident Mode

Now start FPrint.exe to begin monitoring for commands.

#### Start FPrint (Background - Recommended)
```bash
# Navigate to repository directory
cd datecs-fprint-macos

# Start FPrint in background
nohup wine FPrintWIN/FPrint.exe /resident > /tmp/fprint.log 2>&1 &

# Check if running
ps aux | grep FPrint.exe

# View logs (optional)
tail -f /tmp/fprint.log
```

#### Start FPrint (Foreground - For Testing)
```bash
# Navigate to repository directory
cd datecs-fprint-macos

# Start FPrint (you'll see output directly)
wine FPrintWIN/FPrint.exe /resident
```

FPrint is now running and monitoring `C:\FPrintCommands` for command files!

### Step 6: Test the Setup

#### Test: Send a Command
1. Create a test command file:
   ```bash
   echo "I,1,______,_,__;0;80" > ~/.wine/drive_c/FPrintCommands/test01.txt
   ```
2. FPrint.exe (running via Wine) will:
   - Detect the file
   - Parse the command
   - Send to printer via TCP/IP
   - Write result to results folder
3. Check the result:
   ```bash
   cat ~/.wine/drive_c/FPrintResults/test01.txt
   ```

#### Test 3: Monitor in the App
- Go to **Resident Mode** tab in the app
- You should see real-time updates as files are processed
- Check **Activity Logs** tab for detailed information

## Printer Information

### Finding Your Printer's IP Address

#### Method 1: From Printer Menu
1. Access printer's service menu (usually a button combination)
2. Navigate to "Network Settings" or "Information"
3. Note the IP address displayed

#### Method 2: Router/Network Scanner
1. Log into your router's admin panel
2. Check connected devices list
3. Find device named "Datecs" or matching the MAC address

#### Method 3: Network Scan
```bash
# Install nmap
brew install nmap

# Scan your network (replace with your network range)
nmap -p 4999 192.168.1.0/24

# Look for open port 4999
```

### Finding Serial Number and Fiscal Memory Number

1. Access printer's service menu
2. Navigate to "Device Information" or "About"
3. Note down:
   - **Serial Number** (usually starts with letters + numbers)
   - **Fiscal Memory Number** (numeric)

## Advanced Configuration

### Custom Wine Prefix

If you want to isolate FPrint in its own Wine environment:

```bash
# Create a separate Wine prefix for FPrint
export WINEPREFIX=~/.wine-fprint
winecfg

# Install FPrint to this prefix
wine /path/to/FPrintSetup.exe

# Run FPrint with this prefix
WINEPREFIX=~/.wine-fprint wine FPrint.exe /resident
```

### Auto-start FPrint on Boot

Create a LaunchAgent to start FPrint automatically:

```bash
# Create LaunchAgent directory if needed
mkdir -p ~/Library/LaunchAgents

# Create plist file
nano ~/Library/LaunchAgents/com.datecs.fprint.plist
```

**Content:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.datecs.fprint</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/wine</string>
        <string>/Users/YOUR_USERNAME/.wine/drive_c/Program Files/Datecs/FPrint/FPrint.exe</string>
        <string>/resident</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/fprint.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/fprint.err</string>
</dict>
</plist>
```

**Load the agent:**
```bash
launchctl load ~/Library/LaunchAgents/com.datecs.fprint.plist

# Stop it:
launchctl unload ~/Library/LaunchAgents/com.datecs.fprint.plist
```

### Logging and Debugging

#### Enable Wine Debug Logging
```bash
# Set Wine debug level
export WINEDEBUG=+all

# Run FPrint with full logging
wine FPrint.exe /resident > ~/fprint-wine.log 2>&1
```

#### FPrint Log Files
Check FPrint's own logs:
```bash
# Typical location
cat ~/.wine/drive_c/Program\ Files/Datecs/FPrint/fprint.log
```

## Troubleshooting

### Wine Issues

#### Wine Not Found
```bash
# Verify installation
which wine
wine --version

# Reinstall if needed
brew reinstall wine-stable
```

#### Wine Configuration
```bash
# Open Wine configuration
winecfg

# Check:
# - Windows version (try Windows 10)
# - Graphics settings
# - Drive mappings
```

### FPrint Issues

#### FPrint Won't Start
```bash
# Check dependencies
wine FPrint.exe

# Look for missing DLL errors
# Install required Windows components:
winetricks dotnet40
winetricks vcrun2019
```

#### FPrint Not Processing Files
1. Check ExecutionFolder in config matches created folder
2. Verify file permissions
3. Check FPrint log for errors
4. Test with simple command manually

### Printer Issues

#### Can't Connect to Printer
```bash
# Test TCP connection
nc -zv PRINTER_IP 4999

# Or use telnet
telnet PRINTER_IP 4999
```

If connection works but FPrint can't communicate:
- Verify IP in FPrint config matches printer IP
- Check firewall (both macOS and printer)
- Verify printer is in fiscal mode
- Check printer network settings

#### Commands Not Working
- Verify command format matches Datecs protocol
- Check printer model is correct in config
- Review FPrint documentation for command syntax
- Test with simple commands first (device info)

### App Issues

#### Electron App Won't Start
```bash
# Check Node.js version
node --version  # Should be 14+

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Try running in dev mode
npm run dev
```

#### Logs Not Showing
- Check file permissions on log files
- Verify Chokidar is watching correct folders
- Check browser console in Electron (View → Developer → Developer Tools)

## Command Examples

### Device Information
```
I,1,______,_,__;0;80
```

### Get Last Document Number
```
N,1,______,_,__;
```

### Open Fiscal Receipt
```
48,1,______,_,__;1;1;1;0;OPERATOR001;
```

### Print Text Line
```
54,1,______,_,__;Hello World!;
```

### Close Fiscal Receipt
```
56,1,______,_,__;
```

## File Locations Reference

| What | Location |
|------|----------|
| FPrint executables | `FPrintWIN/` (in this repo) |
| Settings Manager | `FPrintWIN/FPrint_SettingsManager.exe` |
| FPrint main | `FPrintWIN/FPrint.exe` |
| FPrint config | `FPrintWIN/FPrint.ini`, `FPrintWIN/Settings.dat` |
| Command files | `~/.wine/drive_c/FPrintCommands/` (or as configured) |
| Result files | `~/.wine/drive_c/FPrintResults/` (or as configured) |
| FPrint logs | `/tmp/fprint.log` (if using nohup) |
| Wine C: drive | `~/.wine/drive_c/` |

## Support

### Getting Help
1. Check FPrint logs: `tail -f /tmp/fprint.log`
2. Review [GitHub Issues](https://github.com/bulgariamitko/datecs-fprint-macos/issues)
3. Consult Datecs FPrint documentation
4. Visit [WineHQ](https://www.winehq.org/) for Wine-specific issues

### Reporting Issues
When reporting issues, include:
- macOS version
- Wine version (`wine --version`)
- Printer model
- Error messages from FPrint logs (`/tmp/fprint.log`)
- Steps to reproduce the issue

---

**Once setup is complete, you'll have a fully functional Datecs FPrint environment on macOS!** 🎉

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

### Step 2: Install Windows FPrint

You need the official Windows FPrint software from Datecs.

#### Option A: Using Wine to Run Installer

```bash
# Download FPrint installer from Datecs website
# Then run it with Wine:
wine /path/to/FPrintSetup.exe

# Follow the installation wizard
# Default installation path: C:\Program Files\Datecs\FPrint\
```

#### Option B: Manual Installation

```bash
# Create the FPrint directory
mkdir -p ~/.wine/drive_c/Program\ Files/Datecs/FPrint/

# Copy FPrint.exe and related files to the directory
cp /path/to/FPrint.exe ~/.wine/drive_c/Program\ Files/Datecs/FPrint/
cp /path/to/*.dll ~/.wine/drive_c/Program\ Files/Datecs/FPrint/

# Verify installation
ls ~/.wine/drive_c/Program\ Files/Datecs/FPrint/FPrint.exe
```

#### Option C: Extract from Installer

```bash
# Use 7-Zip or similar to extract FPrint installer
brew install p7zip
7z x FPrintSetup.exe -o/tmp/fprint_extracted

# Copy files to Wine directory
mkdir -p ~/.wine/drive_c/Program\ Files/Datecs/FPrint/
cp /tmp/fprint_extracted/* ~/.wine/drive_c/Program\ Files/Datecs/FPrint/
```

### Step 3: Configure FPrint (Windows Side)

FPrint needs to be configured with your printer settings. This is typically done via `DatecsFPrint.config` file.

#### Create/Edit Configuration File

```bash
# The config file location (inside Wine's filesystem)
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

**Adjust these values:**
- `IPAddress` - Your printer's IP address
- `Port` - Usually 4999
- `DeviceModel` - Your printer model (DP-25MX, DP-50X, etc.)
- `SerialNumber` - From printer's info menu
- `FiscalMemoryNumber` - From printer's info menu
- `ExecutionFolder` - Where FPrint watches for command files

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

### Step 5: Install DatecsFPrint for macOS

Now install the Electron app that provides the UI.

```bash
# Clone the repository
git clone https://github.com/bulgariamitko/datecs-fprint-macos.git
cd datecs-fprint-macos

# Install dependencies
npm install

# Start in development mode
npm run dev
```

### Step 6: Configure the macOS App

1. Launch the DatecsFPrint app
2. Go to **Settings** tab
3. Enter your printer information:
   - IP Address (e.g., `192.168.1.155`)
   - Port (default: `4999`)
   - Device Model (e.g., `DP-25MX`)
   - Serial Number
   - Fiscal Memory Number
4. Click **Save Configuration**

### Step 7: Start FPrint in Resident Mode

The app can automatically start FPrint.exe via Wine, or you can start it manually:

#### Automatic (via the app)
- The app will detect Wine and FPrint.exe
- Click "Start Resident Mode" in the app
- The app will run: `wine FPrint.exe /resident` in the background

#### Manual
```bash
# Start FPrint in resident mode
wine ~/.wine/drive_c/Program\ Files/Datecs/FPrint/FPrint.exe /resident

# This will run in the background, monitoring the ExecutionFolder for command files
```

#### Check if Running
```bash
# Check if FPrint process is running
ps aux | grep FPrint.exe

# You should see output like:
# user  12345  wine FPrint.exe /resident
```

### Step 8: Test the Setup

#### Test 1: Connection Test
1. In the app, go to **Connection Tester** tab
2. Click **Test Connection**
3. Should see success message

#### Test 2: Send a Command
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
| Wine C: drive | `~/.wine/drive_c/` |
| FPrint.exe | `~/.wine/drive_c/Program Files/Datecs/FPrint/FPrint.exe` |
| FPrint config | `~/.wine/drive_c/Program Files/Datecs/FPrint/DatecsFPrint.config` |
| Command files | `~/.wine/drive_c/FPrintCommands/` (or as configured) |
| Result files | `~/.wine/drive_c/FPrintResults/` (or as configured) |
| macOS app config | `~/.datecs-settings` |
| Electron cache | `~/Library/Application Support/DatecsFPrint` |

## Support

### Getting Help
1. Check the **Logs** tab in the app for error messages
2. Review Wine logs: `tail -f ~/.wine/drive_c/Program\ Files/Datecs/FPrint/fprint.log`
3. Check [GitHub Issues](https://github.com/bulgariamitko/datecs-fprint-macos/issues)
4. Consult Datecs FPrint documentation
5. Visit [WineHQ](https://www.winehq.org/) for Wine-specific issues

### Reporting Issues
When reporting issues, include:
- macOS version
- Wine version (`wine --version`)
- Node.js version (`node --version`)
- Printer model
- Error messages from app logs
- Error messages from Wine/FPrint logs

---

**Once setup is complete, you'll have a fully functional Datecs FPrint environment on macOS!** 🎉

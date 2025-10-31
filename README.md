# DatecsFPrint for macOS

[![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://www.apple.com/macos/)
[![Electron](https://img.shields.io/badge/Electron-22.0+-green.svg)](https://electronjs.org/)
[![React](https://img.shields.io/badge/React-18.2+-blue.svg)](https://reactjs.org/)
[![Wine](https://img.shields.io/badge/Wine-8.0+-red.svg)](https://www.winehq.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern **Electron + React** desktop application that brings Windows FPrint functionality to macOS users with Datecs fiscal printers. Uses Wine to run the native Windows FPrint.exe in the background, providing 100% compatibility with all Datecs printer features.

## 🚀 Why DatecsFPrint for macOS?

If you're using **Datecs fiscal printers** on macOS and need the full Windows FPrint functionality, this app is for you! It provides:

- ✅ **100% Windows FPrint compatibility** via Wine integration
- ✅ **Modern Electron + React** UI for easy management
- ✅ **Native macOS experience** with cross-platform compatibility
- ✅ **Automatic Wine setup** - handles FPrint.exe in background
- ✅ **Real-time connection testing** with beautiful UI
- ✅ **Resident mode monitoring** for command file processing
- ✅ **Live logging** and comprehensive error handling
- ✅ **Easy configuration** with persistent settings

## 🎯 How It Works

This application uses a **hybrid approach** for maximum compatibility:

1. **Wine Backend**: Runs the official Windows `FPrint.exe` in the background using Wine
2. **Modern UI**: Provides a sleek Electron + React interface for configuration and monitoring
3. **File-Based Communication**: Manages command files that FPrint.exe processes (resident mode)
4. **Automatic Management**: Handles Wine installation, FPrint setup, and process management

```
┌─────────────────────────────────────┐
│   Electron + React UI (macOS)       │
│   - Configuration                   │
│   - Monitoring                      │
│   - Logging                         │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Wine Layer                        │
│   Runs FPrint.exe in background     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Datecs Fiscal Printer (TCP/IP)    │
└─────────────────────────────────────┘
```

## 📦 Supported Datecs Printers

All Datecs fiscal printers supported by Windows FPrint:

| Model Series | Status | Notes |
|--------------|--------|-------|
| **DP-25MX** | ✅ Tested | Full feature support |
| **DP-50X** | ✅ Compatible | Network-enabled models |
| **FP-2000** | ✅ Compatible | TCP/IP variants |
| **All Models** | ✅ Compatible | If supported by Windows FPrint |

## 🛠️ Quick Start

### Prerequisites

- **macOS 14.0+** (Sonoma or later)
- **Node.js 14+** and npm
- **Wine** (automatically installed if needed)
- **Datecs fiscal printer** with network connectivity (TCP/IP)
- **FPrint.exe** (Windows FPrint installer)

### Installation

#### Option 1: Download Release (Coming Soon)
Pre-built macOS app will be available in [Releases](../../releases)

#### Option 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/bulgariamitko/datecs-fprint-macos.git
cd datecs-fprint-macos

# Install dependencies
npm install

# Start development mode
npm run dev
```

### First-Time Setup

1. **Install Wine** (if not already installed):
   ```bash
   # Using Homebrew
   brew install wine-stable
   ```

2. **Setup FPrint.exe**:
   - Download the Windows FPrint installer from Datecs
   - Run the installer using Wine: `wine FPrintSetup.exe`
   - Or place `FPrint.exe` in `~/.wine/drive_c/Program Files/Datecs/FPrint/`

3. **Configure the Application**:
   - Launch DatecsFPrint for macOS
   - Go to Settings tab
   - Enter printer IP address (e.g., `192.168.1.155`)
   - Enter port (default: `4999`)
   - Add printer details (model, serial number)
   - Click "Save Configuration"

4. **Start FPrint Service**:
   - The app will automatically start FPrint.exe in the background via Wine
   - Resident mode will monitor command files
   - Check logs to verify FPrint is running

5. **Test the Connection**:
   - Use the Connection Tester tab
   - Send a test command
   - Monitor the Activity Logs

## 🎯 Features

### ✨ Core Features
- **Wine Integration** - Seamless Windows FPrint.exe execution on macOS
- **Automatic Process Management** - Starts/stops FPrint.exe as needed
- **Resident Mode** - File-based command processing
- **Real-time Monitoring** - Live status and logging
- **Configuration Management** - Settings saved automatically
- **Connection Testing** - Built-in diagnostics

### 🖥️ User Interface
- **Modern React UI** - Clean, intuitive design
- **Resident Mode Monitor** - Watch command files being processed
- **Connection Tester** - Step-by-step connection verification
- **Activity Logs** - Real-time command/response viewer
- **Settings Panel** - Easy printer and Wine configuration
- **Status Indicators** - Visual feedback for FPrint and printer state

### 🔧 Developer Features
- **Modular Architecture** - Easy to extend
- **Well-documented** - See [docs/](docs/) for details
- **Process Isolation** - Wine runs in separate process
- **Error Recovery** - Automatic FPrint restart on failures

## 📖 Usage

### Using the Desktop App

1. **Start the app:**
   ```bash
   npm run dev
   ```

2. **Configure your printer** in the Settings tab

3. **The app automatically**:
   - Starts FPrint.exe via Wine in resident mode
   - Monitors command files in the designated folder
   - Processes commands and sends to printer
   - Displays results in Activity Logs

4. **Monitor activity** in the Resident Mode and Logs tabs

### Resident Mode

The application uses file-based communication with FPrint:

1. Command files are created in: `~/.datecs-fprint/commands/`
2. FPrint.exe (running via Wine) monitors this folder
3. When a file appears, FPrint processes it
4. Results are written to: `~/.datecs-fprint/results/`
5. The UI displays real-time updates

### Manual FPrint Control

You can also control FPrint manually:

```bash
# Start FPrint in resident mode
wine ~/.wine/drive_c/Program\ Files/Datecs/FPrint/FPrint.exe /resident

# Stop FPrint
pkill -f FPrint.exe
```

## 📁 Project Structure

```
datecs-fprint-macos/
├── src/                          # React application source
│   ├── App.js                    # Main React component
│   ├── components/               # UI components
│   │   ├── ConfigurationPanel.js # Settings UI
│   │   ├── ConnectionTester.js   # Connection testing
│   │   ├── InfoTooltip.js        # Help tooltips
│   │   ├── ResidentMode.js       # Resident mode monitor
│   │   └── LogViewer.js          # Activity logs
│   └── index.js                  # React entry point
├── public/                       # Electron main process
│   ├── electron.js               # Main Electron script
│   └── index.html                # HTML template
├── docs/                         # Technical documentation
├── datecs_printer_complete.js    # Printer protocol module
├── test_*.js                     # Test scripts
├── *.sh                          # Shell utilities
├── package.json                  # Dependencies
└── README.md                     # This file
```

## 🧪 Development

### Available Scripts

```bash
# Development mode (React + Electron)
npm run dev

# Build React app
npm run build

# Build desktop app (dmg/exe/AppImage)
npm run dist

# Run Electron only
npm run electron

# Run React only
npm start

# Run tests
npm test
```

### Tech Stack

- **Electron 22+** - Desktop framework
- **React 18+** - UI library
- **Node.js** - Backend functionality
- **Wine 8+** - Windows compatibility layer
- **Chokidar** - File system monitoring
- **Lucide React** - Icons

## 🚨 Troubleshooting

### Wine Issues

✅ **Check Wine installation:**
```bash
wine --version
```

✅ **Verify FPrint.exe location:**
```bash
ls ~/.wine/drive_c/Program\ Files/Datecs/FPrint/FPrint.exe
```

✅ **Check if FPrint is running:**
```bash
ps aux | grep FPrint.exe
```

✅ **Wine logs:**
```bash
tail -f ~/.wine/drive_c/Program\ Files/Datecs/FPrint/fprint.log
```

### Printer Not Connecting?

✅ **Check these first:**
- Printer is powered on
- Printer has network connection (Ethernet/WiFi)
- IP address is correct (check printer display)
- Port 4999 is correct (standard for Datecs)
- Mac and printer are on same network
- Firewall not blocking port 4999
- FPrint.exe is running (check Activity Logs)

### App Issues?

✅ **Try these fixes:**

```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Clear Electron cache
rm -rf ~/Library/Application\ Support/DatecsFPrint

# Reset configuration
rm ~/.datecs-settings

# Restart FPrint
pkill -f FPrint.exe
# App will automatically restart it

# Check Node.js version
node --version  # Should be 14+

# Check Wine version
wine --version  # Should be 8.0+
```

### Still Having Issues?

1. Check the **Logs tab** in the app for detailed error messages
2. Review [technical documentation](docs/)
3. Check Wine logs at `~/.wine/drive_c/Program Files/Datecs/FPrint/fprint.log`
4. Open an [issue](../../issues) on GitHub with logs

## 📚 Documentation

All technical documentation is in the [`docs/`](docs/) folder:

- **[docs/README.md](docs/README.md)** - Documentation index
- **[docs/DATECS_SOLUTION_COMPLETE.md](docs/DATECS_SOLUTION_COMPLETE.md)** - Protocol documentation
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Detailed setup instructions

## 🧪 Experimental: Native Protocol Implementation

We're also working on a **native macOS implementation** that doesn't require Wine. This is experimental work to decode the Datecs protocol for native Node.js support.

📁 **See [experimental/native-protocol/](experimental/native-protocol/)** for:
- Native protocol decoder (work in progress)
- Test scripts and utilities
- Protocol analysis tools
- Contribution guide for protocol decoding

**Note**: The Wine approach is the recommended production solution. The native protocol work is experimental and not yet feature-complete. Contributions welcome!

## 📋 Roadmap

### ✅ Completed
- [x] Electron + React architecture
- [x] Modern responsive UI
- [x] Configuration management
- [x] Connection testing
- [x] Wine integration for FPrint.exe
- [x] Resident mode monitoring
- [x] Activity logging

### 🔜 Coming Soon
- [ ] Automatic Wine installation
- [ ] FPrint.exe bundling
- [ ] Enhanced error recovery
- [ ] Multiple printer support
- [ ] Command templates
- [ ] App Store distribution

### 🔮 Future Ideas
- [ ] Command history and replay
- [ ] Advanced diagnostics
- [ ] Print queue management
- [ ] Cloud sync for configurations

### 🧪 Experimental (Native Protocol)
- [x] Basic TCP/IP communication
- [x] Protocol analysis and documentation
- [ ] Complete protocol decoder
- [ ] All FPrint commands implemented
- [ ] Replace Wine with native implementation

## 🤝 Contributing

Contributions welcome! This project uses modern web technologies:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `npm run dev`
5. Submit a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Datecs** for their fiscal printers and FPrint software
- **Wine** project for Windows compatibility on macOS/Linux
- **Electron** for the cross-platform framework
- **React** for the UI library
- **Open source community** for inspiration and support

## 📞 Support

- **Documentation**: [docs/](docs/) folder and [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Issues**: [GitHub Issues](../../issues) for bug reports
- **Discussions**: [GitHub Discussions](../../discussions) for questions
- **Datecs Support**: Contact Datecs for printer hardware issues
- **Wine Support**: [WineHQ](https://www.winehq.org/) for Wine-related issues

---

**Built with ❤️ for the macOS + Datecs community**

*Using Wine to bring Windows FPrint to macOS with a modern UI*

*Star ⭐ this repo if it helped you!*

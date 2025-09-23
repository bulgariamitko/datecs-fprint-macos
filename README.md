# DatecsFPrint for macOS

[![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://www.apple.com/macos/)
[![Electron](https://img.shields.io/badge/Electron-22.0+-green.svg)](https://electronjs.org/)
[![React](https://img.shields.io/badge/React-18.2+-blue.svg)](https://reactjs.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern **Electron + React** desktop application that brings Windows FPrint functionality to Mac users with Datecs fiscal printers. Built with web technologies for easy development and cross-platform compatibility.

![DatecsFPrint Screenshot](https://via.placeholder.com/800x500/667eea/FFFFFF?text=DatecsFPrint+for+macOS+-+Electron+React)

## 🚀 Why DatecsFPrint for macOS?

If you're using **Datecs fiscal printers** on macOS and missing the Windows FPrint functionality, this app is for you! It provides:

- ✅ **Modern Electron + React** architecture for easy development
- ✅ **Cross-platform compatibility** (macOS, Windows, Linux)
- ✅ **Real-time connection testing** with beautiful UI
- ✅ **100% compatibility** with Windows FPrint command format
- ✅ **TCP/IP networking** for modern Ethernet/WiFi printers
- ✅ **Live logging** and comprehensive error handling
- ✅ **Easy configuration** with persistent settings

## 📦 Supported Datecs Printers

This application works with any Datecs fiscal printer that supports TCP/IP communication:

| Model Series | Tested | Notes |
|--------------|--------|-------|
| **DP-25MX** | ✅ Primary | Full feature support |
| **DP-50X** | ✅ Compatible | Network-enabled models |
| **FP-2000** | ✅ Compatible | TCP/IP variants |
| **Other Models** | 🔄 Should work | If it has Ethernet/WiFi |

## 🛠️ Quick Start

### Prerequisites

- **macOS 14.0+** (Sonoma or later)
- **Node.js 14+**
- **npm** or **yarn**
- **Datecs fiscal printer** with network connectivity

### Download & Install

#### Option 1: Download Release (Recommended)
1. Go to [Releases](../../releases)
2. Download the latest `DatecsFPrint-macOS.dmg`
3. Open DMG and drag app to Applications
4. Launch from Applications folder

#### Option 2: Build from Source
```bash
git clone https://github.com/bulgariamitko/datecs-fprint-macos.git
cd datecs-fprint-macos
npm install
npm run dev
```

### First-Time Setup

1. **Launch DatecsFPrint** - Modern Electron app opens
2. **Go to Settings tab** to configure your printer
3. **Enter your printer details:**
   - IP Address (e.g., `192.168.1.100`)
   - Port (usually `4999`)
   - Device Model (e.g., `DP-25MX`)
   - Serial Number (from printer info)
   - Fiscal Memory Number (from printer info)
4. **Click "Save Configuration"**
5. **Test Connection** to verify everything works
6. **Send Test Command** to confirm communication

## 🎯 Features

### 🖥️ Modern UI Features
- **Electron + React** desktop app with native feel
- **Real-time connection status** with visual indicators
- **Interactive connection testing** with step-by-step guidance
- **Live activity logging** with export functionality
- **Persistent configuration** saved locally
- **Clean, intuitive interface** inspired by modern macOS apps

### 🔧 Technical Features
- **TCP/IP communication** with configurable timeouts
- **Command validation** and response parsing
- **Error handling** with detailed logging
- **Cross-platform compatibility** (runs on Windows/Linux too)
- **Developer-friendly** web technologies

### 💻 Developer Features
- **Modern JavaScript** with React components
- **IPC communication** between main and renderer processes
- **File system operations** for configuration management
- **Network abstraction** for TCP communication
- **Easy to extend** and customize

## 📖 Usage Examples

### Basic Connection Test
The app provides a guided connection testing process:

1. **Test TCP Connection** - Verifies network connectivity
2. **Send Test Command** - Sends device information request
3. **View Real-time Logs** - See all communication in detail

### Standard Commands
```
# Get device information
I,1,______,_,__;0;80

# Get last document number
N,1,______,_,__;

# Open fiscal receipt (example)
48,1,______,_,__;1;1;1;0;OPERATOR001;
```

## 🔧 Configuration

Settings are automatically saved to `~/Documents/DatecsFPrint.config`:

```json
{
  "ipAddress": "192.168.1.100",
  "port": 4999,
  "deviceModel": "DP-25MX",
  "serialNumber": "AB123456",
  "fiscalMemoryNumber": "12345678",
  "timeout": 10000
}
```

## 🧪 Development

### Tech Stack
- **Electron 22+** - Desktop app framework
- **React 18+** - UI library
- **Lucide React** - Beautiful icons
- **Node.js** - Backend functionality

### Project Structure
```
├── src/
│   ├── App.js                    # Main React component
│   ├── components/
│   │   ├── ConfigurationPanel.js # Settings UI
│   │   ├── ConnectionTester.js   # Connection testing
│   │   └── LogViewer.js         # Activity logs
│   └── index.js                 # React entry point
├── public/
│   ├── electron.js              # Electron main process
│   └── index.html              # HTML template
├── package.json                # Dependencies and scripts
└── README.md                   # This file
```

### Development Scripts
```bash
# Start development server
npm run dev

# Build for production
npm run build

# Package as desktop app
npm run dist

# Run just Electron
npm run electron

# Run just React
npm start
```

## 🚨 Troubleshooting

### Connection Issues
- ✅ Printer is powered on and connected to network
- ✅ IP address is correct (check printer display/menu)
- ✅ Port 4999 is accessible (default for Datecs)
- ✅ Firewall allows the connection
- ✅ Printer and Mac are on same network

### App Issues
- ✅ macOS 14.0+ is required
- ✅ Node.js 14+ is installed
- ✅ App has network permissions
- ✅ Check logs in the app's Log Viewer

### Common Fixes
```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Clear Electron cache
rm -rf ~/Library/Application\ Support/DatecsFPrint

# Reset configuration
rm ~/Documents/DatecsFPrint.config
```

## 🤝 Contributing

Contributions are welcome! The modern web tech stack makes it easy to contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes in React/JavaScript
4. Test with `npm run dev`
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Setup
```bash
git clone https://github.com/bulgariamitko/datecs-fprint-macos.git
cd datecs-fprint-macos
npm install
npm run dev
```

## 📋 Roadmap

- [x] **Electron + React** architecture
- [x] **TCP/IP communication** with real-time testing
- [x] **Modern UI** with connection status and logging
- [x] **Configuration management** with persistence
- [x] **Cross-platform compatibility**
- [ ] **Serial (RS-232)** communication support
- [ ] **File processing** and resident mode
- [ ] **Command history** and templates
- [ ] **Multiple printer** support
- [ ] **App Store distribution**

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Datecs** for their fiscal printer protocol documentation
- **Electron** for the amazing cross-platform framework
- **React** for the powerful UI library
- **Community** contributors and testers

## 📞 Support

- **Documentation**: Check [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions
- **Issues**: Open an [issue](../../issues) on GitHub
- **Discussions**: Use [GitHub Discussions](../../discussions) for questions
- **Datecs Support**: Contact Datecs for printer-specific issues

---

**Built with modern web technologies for the macOS + Datecs community** 💻⚡

*If this project helped you, please ⭐ star it on GitHub!*
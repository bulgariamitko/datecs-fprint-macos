# DatecsFPrint for macOS

[![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A native macOS application that brings Windows FPrint functionality to Mac users with Datecs fiscal printers. Built with SwiftUI for a modern, native macOS experience.

![DatecsFPrint Screenshot](https://via.placeholder.com/800x500/2196F3/FFFFFF?text=DatecsFPrint+for+macOS)

## 🚀 Why DatecsFPrint for macOS?

If you're using **Datecs fiscal printers** on macOS and missing the Windows FPrint functionality, this app is for you! It provides:

- ✅ **100% compatibility** with Windows FPrint command format
- ✅ **Native macOS interface** built with SwiftUI
- ✅ **TCP/IP networking** for modern Ethernet/WiFi printers
- ✅ **Resident mode** for automatic file processing
- ✅ **Command-line interface** for automation and scripting
- ✅ **Real-time logging** and comprehensive error handling

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
- **Datecs fiscal printer** with network connectivity
- **Xcode 15.0+** (for building from source)

### Download & Install

#### Option 1: Download Release (Recommended)
1. Go to [Releases](../../releases)
2. Download the latest `DatecsFPrint.app.zip`
3. Extract and move to Applications folder
4. Launch the app

#### Option 2: Build from Source
```bash
git clone https://github.com/YOUR_USERNAME/datecs-fprint-macos.git
cd datecs-fprint-macos
./build_and_run.sh
```

### First-Time Setup

1. **Launch DatecsFPrint** - You'll see a welcome screen
2. **Click "Open Settings"** to configure your printer
3. **Enter your printer details:**
   - IP Address (e.g., `192.168.1.100`)
   - Port (usually `4999`)
   - Device Model (e.g., `DP-25MX`)
   - Serial Number (from printer info)
   - Fiscal Memory Number (from printer info)
4. **Test Connection** to verify everything works
5. **Start using** the app!

## 🎯 Features

### 🖥️ GUI Features
- **First-time setup wizard** for easy configuration
- **Real-time connection status** indicator
- **Interactive log viewer** with filtering
- **Settings panel** with all Windows FPrint options
- **Test connection** functionality

### 🤖 Automation Features
- **Resident Mode**: Monitor folders for `.FP` files
- **Automatic processing** with configurable intervals
- **Answer file generation** in standard format
- **File management** (move to executed folder)

### 💻 Developer Features
- **CLI mode** for scripting and automation
- **JSON configuration** files
- **Comprehensive logging** system
- **Error code mapping** identical to Windows version

## 📖 Usage Examples

### Basic Connection Test
```bash
# Test your printer connection
python3 simple_tcp_test.py 192.168.1.100 4999
```

### Command-Line Usage
```bash
# Process a single file
./DatecsFPrint.app/Contents/MacOS/DatecsFPrint 192.168.1.100 4999 commands.FP AB123456
```

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

Settings are saved in `~/Documents/DatecsFPrint.config` as JSON:

```json
{
  "ipAddress": "192.168.1.100",
  "port": 4999,
  "deviceModel": "DP-25MX",
  "serialNumber": "AB123456",
  "fiscalMemoryNumber": "12345678",
  "executionFolderPath": "/Users/username/Desktop/FPrint",
  "logFolderPath": "/Users/username/Desktop/FPrint/Logs"
}
```

## 🧪 Testing Your Setup

### 1. Quick System Test
```bash
./quick_test.swift
```

### 2. View Current Configuration
```bash
./view_config.sh
```

### 3. Test Printer Connection
```bash
python3 simple_tcp_test.py YOUR_PRINTER_IP 4999
```

## 📁 Project Structure

```
DatecsFPrint/
├── DatecsFPrint.xcodeproj     # Xcode project
├── DatecsFPrint/              # Source code
│   ├── DatecsFPrintApp.swift  # App entry point
│   ├── ContentView.swift      # Main UI
│   ├── SettingsView.swift     # Configuration UI
│   ├── Models/                # Data models
│   └── Services/              # Core services
├── README.md                  # This file
├── SETUP_GUIDE.md            # Detailed setup instructions
├── FEATURES.md               # Complete feature list
├── simple_tcp_test.py        # Connection test script
├── example_config.json       # Sample configuration
└── build_and_run.sh         # Build script
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
- ✅ App has network permissions
- ✅ Configuration file is valid JSON
- ✅ Check logs in `~/Documents/DatecsFPrint/Logs/`

### Common Fixes
```bash
# Reset configuration
rm ~/Documents/DatecsFPrint.config

# Check app permissions
spctl --assess --verbose DatecsFPrint.app

# Test network connectivity
ping YOUR_PRINTER_IP
telnet YOUR_PRINTER_IP 4999
```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup
```bash
git clone https://github.com/YOUR_USERNAME/datecs-fprint-macos.git
cd datecs-fprint-macos
open DatecsFPrint.xcodeproj
```

## 📋 Roadmap

- [x] TCP/IP communication
- [x] GUI application with SwiftUI
- [x] Resident mode file watching
- [x] CLI mode support
- [x] Configuration management
- [x] Comprehensive logging
- [ ] Serial (RS-232) communication
- [ ] App Store distribution
- [ ] Code signing and notarization
- [ ] Localization support

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Datecs** for their fiscal printer protocol documentation
- **Apple** for SwiftUI and excellent macOS development tools
- **Community** contributors and testers

## 📞 Support

- **Documentation**: Check [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions
- **Issues**: Open an [issue](../../issues) on GitHub
- **Discussions**: Use [GitHub Discussions](../../discussions) for questions
- **Datecs Support**: Contact Datecs for printer-specific issues

---

**Made with ❤️ for the macOS + Datecs community**

*If this project helped you, please ⭐ star it on GitHub!*
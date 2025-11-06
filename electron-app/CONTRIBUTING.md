# Contributing to DatecsFPrint for macOS

Thank you for considering contributing to DatecsFPrint for macOS! This document provides guidelines and information for contributors.

## 🎯 How to Contribute

### Reporting Issues
- **Check existing issues** first to avoid duplicates
- **Use issue templates** when available
- **Provide detailed information**:
  - macOS version
  - Wine version (if applicable)
  - Node.js version
  - Datecs printer model
  - Steps to reproduce
  - Expected vs actual behavior
  - Logs (from app and Wine if applicable)

### Suggesting Features
- **Open a discussion** first for major features
- **Explain the use case** and why it's needed
- **Consider compatibility** with existing Datecs printers

## 💻 Contributing to the Application (Wine-based)

This is the **main production application** using Electron + React + Wine.

### Getting Started
1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/datecs-fprint-macos.git
   cd datecs-fprint-macos
   ```
3. **Install dependencies**:
   ```bash
   npm install
   ```
4. **Install Wine** (for testing):
   ```bash
   brew install wine-stable
   ```

### Development Environment
- **macOS 14.0+** (Sonoma or later)
- **Node.js 14+**
- **npm** or **yarn**
- **Wine 8.0+**
- **Electron 22+**
- **React 18+**

### Project Structure
```
├── src/                    # React UI components
│   ├── App.js              # Main application
│   ├── components/         # React components
│   │   ├── ConfigurationPanel.js
│   │   ├── ConnectionTester.js
│   │   ├── ResidentMode.js
│   │   ├── InfoTooltip.js
│   │   └── LogViewer.js
│   └── index.js            # React entry
├── public/
│   ├── electron.js         # Electron main process
│   └── index.html          # HTML template
└── docs/                   # Documentation
```

### Code Style Guidelines
- **JavaScript/React conventions**: ES6+, functional components
- **React hooks**: Use hooks for state management
- **Comments**: Add JSDoc comments for functions
- **Error handling**: Always handle errors gracefully
- **Logging**: Use console with proper levels

### Testing
- **Test on real hardware** when possible
- **Run in development mode**:
  ```bash
  npm run dev
  ```
- **Test Wine integration**: Verify FPrint.exe communication
- **Test all tabs**: Settings, Connection Tester, Resident Mode, Logs
- **Verify configuration persistence**

### Submitting Changes
1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. **Make your changes**
3. **Test thoroughly**
4. **Commit with clear messages**:
   ```bash
   git commit -m "Add support for XYZ feature"
   ```
5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
6. **Open a Pull Request**

## 🧪 Contributing to Native Protocol (Experimental)

This is **experimental work** to decode the Datecs protocol for native Node.js support without Wine.

### Why Contribute to Native Protocol?

The goal is to eventually eliminate the Wine dependency by implementing native protocol support. This is valuable work but requires:
- Protocol reverse engineering
- Hardware testing
- Extensive documentation
- Patience and persistence

### Getting Started with Protocol Work

1. **Read the documentation**:
   - [experimental/native-protocol/README.md](experimental/native-protocol/README.md)
   - [docs/DATECS_SOLUTION_COMPLETE.md](docs/DATECS_SOLUTION_COMPLETE.md)
   - [docs/DATECS_PROTOCOL_ANALYSIS.md](docs/DATECS_PROTOCOL_ANALYSIS.md)

2. **Set up your environment**:
   ```bash
   cd experimental/native-protocol
   npm install  # if needed
   ```

3. **Test with your printer**:
   ```bash
   node send_test_print.js
   ```

### Protocol Research Process

1. **Capture traffic** from Windows FPrint.exe:
   ```bash
   # On macOS with printer
   sudo ./capture_printer_traffic.sh

   # On Windows with Wireshark
   # Capture FPrint.exe → Printer traffic on port 4999
   ```

2. **Analyze packets**:
   ```bash
   ./analyze_capture.sh capture.pcap
   ```

3. **Document findings** in `docs/DATECS_PROTOCOL_ANALYSIS.md`:
   - New commands discovered
   - Parameter formats
   - Response structures
   - Error codes

4. **Implement in code**:
   - Update `datecs_printer_complete.js`
   - Add new command methods
   - Implement response parsing
   - Add error handling

5. **Write tests**:
   - Create test scripts
   - Test with real hardware
   - Document test results

6. **Submit PR** with:
   - Code changes
   - Documentation updates
   - Test results
   - Hardware tested on

### Protocol Contribution Guidelines

#### Do's ✅
- **Test with real Datecs hardware**
- **Document everything** you discover
- **Share findings** even if incomplete
- **Ask questions** in GitHub issues
- **Collaborate** with other contributors
- **Follow existing code patterns**
- **Add comprehensive error handling**

#### Don'ts ❌
- **Don't guess** protocol behavior
- **Don't skip testing** with hardware
- **Don't break** existing working code
- **Don't assume** all models work the same
- **Don't submit** untested code
- **Don't redistribute** proprietary Datecs code

### Protocol Work Areas

#### High Priority
- **Complete command set**: Implement all FPrint commands
- **Error handling**: Proper error codes and recovery
- **Multi-model support**: Test and support different printer models
- **Documentation**: Complete protocol documentation

#### Medium Priority
- **Performance**: Optimize communication speed
- **Advanced features**: X/Z reports, programming
- **Edge cases**: Handle unusual scenarios
- **Test coverage**: Comprehensive test suite

#### Low Priority
- **Protocol extensions**: Custom commands
- **Alternative transports**: Serial, Bluetooth
- **Protocol tools**: GUI protocol analyzer

## 📋 Areas Needing Help

### Wine-based Application (Production)
- [ ] **Automatic Wine installation** in the app
- [ ] **FPrint.exe bundling** with the app
- [ ] **Enhanced error recovery** for Wine/FPrint failures
- [ ] **Multiple printer support**
- [ ] **Command templates** and presets
- [ ] **UI/UX improvements**
- [ ] **App Store preparation**

### Native Protocol (Experimental)
- [ ] **Complete protocol decoder**
- [ ] **All FPrint commands** implemented
- [ ] **Multi-model testing** (DP-25MX, DP-50X, FP-2000, etc.)
- [ ] **Comprehensive documentation**
- [ ] **Error handling** and recovery
- [ ] **Performance optimization**
- [ ] **Test coverage**

### Documentation
- [ ] **Video tutorials** for setup
- [ ] **More examples** of common tasks
- [ ] **Troubleshooting guide** expansion
- [ ] **Protocol documentation** completion
- [ ] **API documentation** for developers

## 🧪 Testing Guidelines

### For Application Changes

Before submitting:
- [ ] **App builds successfully**: `npm run build`
- [ ] **No console errors**: Check browser console in Electron
- [ ] **Settings save/load correctly**
- [ ] **Wine integration works** (if applicable)
- [ ] **All UI tabs function** properly
- [ ] **Logs are generated** correctly
- [ ] **README is updated** if needed

### For Protocol Changes

Before submitting:
- [ ] **Code tested with real printer**
- [ ] **Printer model documented**
- [ ] **Protocol analysis included**
- [ ] **Test scripts updated**
- [ ] **Documentation updated**
- [ ] **Edge cases considered**
- [ ] **Error handling tested**

## 📝 Commit Message Guidelines

Use clear, descriptive commit messages:

### Format
```
Brief description (50 chars max)

Detailed explanation of what and why:
- What changed
- Why it changed
- Any breaking changes
- Related issues

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Examples

**Application feature:**
```
Add resident mode file monitoring

- Implement Chokidar-based file watcher
- Add UI panel to display processing status
- Update Electron IPC for file events
- Add configuration for watch directories

Closes #123
```

**Protocol work:**
```
Decode X Report command (69)

- Analyze packet captures from FPrint.exe
- Implement command parser for cmd 69
- Add response handler for X Report data
- Test with DP-25MX printer
- Document findings in DATECS_PROTOCOL_ANALYSIS.md

Tested on: DP-25MX (Serial: DA020990)
```

## 🔍 Code Review Process

1. **Automated checks** (if any) must pass
2. **Manual review** by maintainers
3. **Testing verification**:
   - Application: UI/UX testing
   - Protocol: Hardware testing required
4. **Documentation review** if docs changed
5. **Approval** by maintainer
6. **Merge** to main branch

## 🎓 Learning Resources

### For Application Development
- [Electron Documentation](https://www.electronjs.org/docs)
- [React Documentation](https://react.dev/)
- [Node.js Documentation](https://nodejs.org/docs)
- [Wine Documentation](https://www.winehq.org/documentation)

### For Protocol Research
- [Wireshark User Guide](https://www.wireshark.org/docs/)
- [TCP/IP Protocol Analysis](https://www.tcpdump.org/)
- Datecs printer manuals (if available)
- [docs/](docs/) folder in this repo

## 📞 Getting Help

- **Documentation**: Check [README.md](README.md) and [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Discussions**: Use [GitHub Discussions](../../discussions) for questions
- **Issues**: Report bugs in [Issues](../../issues)
- **Protocol questions**: See [experimental/native-protocol/](experimental/native-protocol/)
- **Wine help**: [WineHQ](https://www.winehq.org/)

## 🎉 Recognition

Contributors will be:
- **Listed in README.md** acknowledgments
- **Tagged in release notes** for their contributions
- **Credited in commits** with Co-Authored-By
- **Invited as collaborators** for significant contributions

## ⚖️ Legal Considerations

### Protocol Reverse Engineering

This project involves reverse engineering for interoperability purposes:
- ✅ **Allowed**: Interoperability reverse engineering
- ✅ **Allowed**: Protocol analysis for compatibility
- ✅ **Allowed**: Testing with legitimate hardware
- ❌ **Not allowed**: Redistributing proprietary code
- ❌ **Not allowed**: Circumventing security measures
- ❌ **Not allowed**: Violating intellectual property

Please:
- Respect intellectual property rights
- Use for legitimate purposes only
- Follow local laws regarding reverse engineering
- Don't distribute Datecs proprietary software

## 📄 License

By contributing, you agree that your contributions will be licensed under the same [MIT License](LICENSE) that covers the project.

---

## 🚀 Quick Start for Contributors

### To contribute to the main app:
```bash
git clone https://github.com/YOUR_USERNAME/datecs-fprint-macos.git
cd datecs-fprint-macos
npm install
npm run dev
# Make changes, test, commit, PR
```

### To contribute to protocol research:
```bash
cd experimental/native-protocol
# Read README.md in that folder
# Run tests with your printer
# Analyze protocol, document findings
# Submit PR with analysis and code
```

---

**Thank you for helping make Datecs printers work better on macOS!** 🙏

*Every contribution, whether code, documentation, testing, or protocol analysis, is valuable and appreciated.*

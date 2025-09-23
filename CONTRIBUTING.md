# Contributing to DatecsFPrint for macOS

Thank you for considering contributing to DatecsFPrint for macOS! This document provides guidelines and information for contributors.

## 🎯 How to Contribute

### Reporting Issues
- **Check existing issues** first to avoid duplicates
- **Use issue templates** when available
- **Provide detailed information**:
  - macOS version
  - Datecs printer model
  - Steps to reproduce
  - Expected vs actual behavior
  - Logs (if applicable)

### Suggesting Features
- **Open a discussion** first for major features
- **Explain the use case** and why it's needed
- **Consider compatibility** with existing Datecs printers

### Contributing Code

#### Getting Started
1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/datecs-fprint-macos.git
   cd datecs-fprint-macos
   ```
3. **Open in Xcode**:
   ```bash
   open DatecsFPrint.xcodeproj
   ```

#### Development Environment
- **macOS 14.0+** (Sonoma or later)
- **Xcode 15.0+**
- **Swift 5.0+**
- **SwiftUI** for UI components

#### Code Style Guidelines
- **Follow Swift conventions**: Use camelCase, proper spacing
- **SwiftUI best practices**: Use proper view composition
- **Comments**: Add comments for complex logic
- **Error handling**: Always handle errors gracefully
- **Logging**: Use the app's Logger for debugging

#### Testing
- **Test on real hardware** when possible
- **Use the provided test scripts**:
  ```bash
  ./quick_test.swift
  python3 simple_tcp_test.py YOUR_PRINTER_IP 4999
  ```
- **Test both GUI and CLI modes**
- **Verify configuration persistence**

#### Submitting Changes
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

## 🏗️ Project Architecture

### Key Components
- **ContentView.swift**: Main application UI
- **SettingsView.swift**: Configuration interface
- **ConfigurationManager.swift**: Settings persistence
- **TCPCommunication.swift**: Network protocol handling
- **CommandParser.swift**: Datecs command processing
- **FileWatcher.swift**: Resident mode functionality
- **Logger.swift**: Logging system

### Design Principles
- **Native macOS experience** using SwiftUI
- **Protocol compatibility** with Windows FPrint
- **Modular architecture** for easy maintenance
- **Comprehensive error handling**
- **User-friendly configuration**

## 🧪 Testing Guidelines

### Before Submitting
- [ ] **App builds successfully** in Xcode
- [ ] **No compiler warnings**
- [ ] **Settings save and load correctly**
- [ ] **TCP communication works** (if you have a printer)
- [ ] **File watcher functions** in resident mode
- [ ] **CLI mode operates** properly
- [ ] **Logs are generated** correctly

### Testing Scenarios
1. **First-time setup**: Fresh config, welcome screen
2. **Settings validation**: Required fields, IP format
3. **Connection testing**: Valid/invalid IPs
4. **File processing**: FP files, answer generation
5. **Error handling**: Network failures, invalid commands

## 📋 Priority Areas

### High Priority
- **Serial communication**: RS-232 support
- **Error handling**: More robust error recovery
- **Performance**: Large file processing optimization
- **Documentation**: Code comments and examples

### Medium Priority
- **Localization**: Multi-language support
- **App Store**: Code signing and distribution
- **Advanced features**: Custom command templates
- **UI improvements**: Better visual feedback

### Low Priority
- **Plugin system**: Custom command processors
- **Remote monitoring**: Web dashboard
- **Cloud integration**: Remote file processing

## 🐛 Known Issues

Check the [Issues](../../issues) page for current known problems and their status.

## 📞 Getting Help

- **Documentation**: Read [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Discussions**: Use [GitHub Discussions](../../discussions)
- **Issues**: Report bugs in [Issues](../../issues)
- **Code questions**: Comment on relevant files

## 🎉 Recognition

Contributors will be:
- **Listed in README.md** acknowledgments
- **Tagged in release notes** for their contributions
- **Invited as collaborators** for significant contributions

## 📝 Commit Message Guidelines

Use clear, descriptive commit messages:

```
Add TCP connection timeout configuration

- Add timeout setting to configuration UI
- Implement timeout in TCPCommunication class
- Update settings validation
- Add tests for timeout functionality
```

Format:
- **First line**: Brief description (50 chars max)
- **Blank line**
- **Details**: What and why (if needed)

## 🔍 Code Review Process

1. **Automated checks** must pass
2. **Manual review** by maintainers
3. **Testing verification** on compatible hardware
4. **Documentation updates** if needed
5. **Merge** after approval

## 📄 License

By contributing, you agree that your contributions will be licensed under the same [MIT License](LICENSE) that covers the project.

---

**Thank you for helping make DatecsFPrint better for the macOS community!** 🙏
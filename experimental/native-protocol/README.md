# Native Protocol Implementation (Experimental)

This folder contains experimental work on implementing a **native macOS protocol decoder** for Datecs fiscal printers. This is an alternative approach to the Wine-based solution currently used in the main application.

## ⚠️ Status: Experimental / Work in Progress

**The main application uses Wine to run Windows FPrint.exe** for 100% compatibility. This experimental work aims to decode the Datecs protocol natively without requiring Windows or Wine.

### Current State
- ✅ Basic TCP/IP communication working
- ✅ Some protocol commands decoded
- ✅ Device information retrieval working
- 🔄 Full protocol not yet complete
- ❌ Not production-ready

## 🎯 Goals

The goal of this experimental work is to:

1. **Fully decode the Datecs printer protocol** used by FPrint.exe
2. **Implement native Node.js/JavaScript** communication without Wine
3. **Provide 100% feature parity** with Windows FPrint
4. **Enable pure macOS/Linux** support without Windows dependencies
5. **Document the protocol** for the community

## 📁 Files in This Folder

### Core Protocol Modules

| File | Description | Status |
|------|-------------|--------|
| `datecs_printer_complete.js` | Complete printer communication module | 🔄 Partial |
| `datecs_printer_module.js` | Base printer protocol implementation | 🔄 Partial |

### Test Scripts

| File | Description |
|------|-------------|
| `test_fiscal_receipt.js` | Test fiscal receipt printing |
| `test_service_commands.js` | Test service/admin commands |
| `test_service_wrapped.js` | Test wrapped command format |
| `send_test_print.js` | Simple print test utility |

### Debug Utilities

| File | Description |
|------|-------------|
| `capture_printer_traffic.sh` | Capture network traffic for analysis |
| `analyze_capture.sh` | Analyze captured packets |
| `test_with_capture.sh` | Run test with packet capture |

## 🚀 How to Use (For Contributors)

### Prerequisites
- Node.js 14+
- Datecs printer with TCP/IP
- Network access to printer
- (Optional) Wireshark for packet analysis

### Basic Testing

1. **Test basic connection:**
   ```bash
   cd experimental/native-protocol
   node send_test_print.js
   ```

2. **Test fiscal receipt:**
   ```bash
   node test_fiscal_receipt.js
   ```

3. **Test service commands:**
   ```bash
   node test_service_commands.js
   ```

### Using the Printer Module

```javascript
const DatecsPrinter = require('./datecs_printer_complete.js');

async function example() {
  const printer = new DatecsPrinter('192.168.1.155', 4999);

  try {
    await printer.connect();
    console.log('Connected!');

    // Get device info
    const info = await printer.getDeviceInfo();
    console.log('Printer info:', info);

    // Print a simple receipt
    await printer.printReceipt([
      'Test Receipt',
      'Item 1: $10.00',
      'Total: $10.00'
    ]);

    await printer.disconnect();
  } catch (error) {
    console.error('Error:', error);
  }
}

example();
```

## 🔍 Protocol Analysis

### What We Know

Based on reverse engineering work (see `../../docs/DATECS_SOLUTION_COMPLETE.md`):

1. **Transport**: TCP/IP on port 4999
2. **Encoding**: Text-based protocol with specific delimiters
3. **Command Format**: CSV-like with semicolon separators
4. **Response Format**: Similar to commands with status codes

### Command Examples

```
# Get device information
I,1,______,_,__;0;80

# Get last document number
N,1,______,_,__;

# Open fiscal receipt
48,1,______,_,__;1;1;1;0;OPERATOR001;

# Print text line
54,1,______,_,__;Hello World!;

# Close fiscal receipt
56,1,______,_,__;
```

### What Needs Work

- ✅ Basic command structure decoded
- 🔄 Complete command set (100+ commands)
- 🔄 Error handling and status codes
- 🔄 Binary data handling (if any)
- ❌ Advanced features (reports, X/Z reports, etc.)
- ❌ All printer models (currently tested on DP-25MX)

## 🤝 Contributing to Protocol Decoding

We welcome contributions to decode the full Datecs protocol! Here's how you can help:

### 1. Capture Traffic

Use the provided scripts to capture traffic between Windows FPrint and the printer:

```bash
# On macOS, capture traffic
sudo ./capture_printer_traffic.sh

# On Windows, use Wireshark to capture FPrint.exe → Printer traffic
```

### 2. Analyze Packets

```bash
./analyze_capture.sh capture_file.pcap
```

Look for:
- Command patterns
- Response formats
- Error codes
- Checksums or validation

### 3. Document Findings

Add to `../../docs/DATECS_PROTOCOL_ANALYSIS.md`:
- New commands discovered
- Command parameters
- Response formats
- Edge cases

### 4. Implement in Code

Update `datecs_printer_complete.js`:
- Add new command methods
- Implement response parsing
- Add error handling
- Write tests

### 5. Test with Real Hardware

**Critical**: Always test with actual Datecs hardware:
- Different printer models
- Different commands
- Error scenarios
- Edge cases

### 6. Submit Pull Request

1. Fork the repository
2. Create a branch: `git checkout -b feature/decode-command-XYZ`
3. Make your changes in `experimental/native-protocol/`
4. Test thoroughly
5. Document your changes
6. Submit PR with detailed description

## 📚 Resources

### Documentation
- `../../docs/DATECS_SOLUTION_COMPLETE.md` - Complete protocol documentation
- `../../docs/DATECS_PROTOCOL_ANALYSIS.md` - Protocol analysis notes
- `../../docs/DLL_ANALYSIS_RESULTS.md` - DLL reverse engineering results

### External Resources
- [Datecs Official Documentation](http://www.datecs.bg/) - If available
- Contact Datecs support for protocol documentation
- Windows FPrint.exe (official reference implementation)

## 🐛 Known Issues

### Current Limitations
1. **Incomplete command set** - Not all FPrint commands implemented
2. **Limited testing** - Primarily tested on DP-25MX
3. **Error handling** - Needs improvement
4. **Documentation gaps** - Some commands not documented

### Why Wine is Still Primary

The Wine approach is used as the main solution because:
- ✅ **100% compatibility** with all FPrint features
- ✅ **All printer models** supported
- ✅ **Official implementation** from Datecs
- ✅ **Production-ready** and stable
- ✅ **No reverse engineering** risk

The native protocol work is experimental to eventually eliminate the Wine dependency.

## 🔧 Development Workflow

### For Protocol Researchers

1. **Capture traffic** from Windows FPrint
2. **Analyze packets** to understand protocol
3. **Document findings** in docs/
4. **Implement in code** here
5. **Test with hardware**
6. **Submit PR**

### For Testers

1. **Run test scripts** with your printer
2. **Report successes/failures** as GitHub issues
3. **Test different models** if you have access
4. **Document printer-specific quirks**

## 📊 Progress Tracker

### Commands Implemented
- [x] Device information (I command)
- [x] Last document number (N command)
- [x] Open fiscal receipt (48)
- [x] Print text (54)
- [x] Close receipt (56)
- [ ] X Report
- [ ] Z Report
- [ ] Department programming
- [ ] Operator management
- [ ] ... (100+ more commands)

### Printer Models Tested
- [x] DP-25MX
- [ ] DP-50X
- [ ] FP-2000
- [ ] Other models

## 🎓 Learning Resources

### Understanding the Protocol

1. **Read the docs** in `../../docs/` folder
2. **Study the code** in `datecs_printer_complete.js`
3. **Run tests** and observe output
4. **Capture traffic** and compare with code
5. **Read Datecs manuals** if available

### Reverse Engineering Tips

- Use Wireshark to capture TCP traffic
- Compare successful commands with failed ones
- Look for patterns in hex dumps
- Test boundary conditions
- Document everything

## 🚧 Roadmap to Native Implementation

### Phase 1: Core Commands (Current)
- [x] Basic communication
- [x] Device info
- [ ] Complete fiscal receipt flow
- [ ] Error handling

### Phase 2: Advanced Features
- [ ] X/Z Reports
- [ ] Department management
- [ ] Operator management
- [ ] Programming commands

### Phase 3: Production Ready
- [ ] All commands implemented
- [ ] Comprehensive error handling
- [ ] Full test coverage
- [ ] Documentation complete
- [ ] Multi-model support

### Phase 4: Integration
- [ ] Replace Wine in main app
- [ ] Migration guide
- [ ] Performance optimization
- [ ] Edge case handling

## 💡 Tips for Contributors

### Do's ✅
- Test with real hardware
- Document everything you discover
- Share findings even if incomplete
- Ask questions in GitHub issues
- Collaborate with other contributors

### Don'ts ❌
- Don't guess protocol behavior
- Don't skip testing
- Don't break existing working code
- Don't assume all models work the same
- Don't submit untested code

## 📞 Getting Help

- **GitHub Issues**: For bugs or questions
- **GitHub Discussions**: For protocol discussions
- **Documentation**: Check `../../docs/` first
- **Community**: Other contributors may have insights

## ⚖️ Legal Note

This work involves reverse engineering for interoperability purposes. Please:
- Respect intellectual property
- Use for legitimate purposes only
- Follow local laws regarding reverse engineering
- Don't distribute proprietary Datecs code

## 🎯 Success Criteria

This experimental work will be considered successful when:

1. ✅ **All FPrint commands** are decoded and implemented
2. ✅ **All printer models** tested and working
3. ✅ **Error handling** is comprehensive
4. ✅ **Documentation** is complete
5. ✅ **Tests pass** on real hardware
6. ✅ **Performance** matches or exceeds Wine approach
7. ✅ **Ready to replace** Wine in production

Until then, **Wine remains the recommended approach** for production use.

---

**Thank you for contributing to making Datecs printers work natively on macOS/Linux!** 🎉

*Remember: This is experimental work. For production use, stick with the Wine-based solution in the main app.*

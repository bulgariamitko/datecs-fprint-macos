# Technical Documentation

This folder contains technical documentation for the Datecs DP-25MX printer integration.

---

## 📄 Documentation

### **[DATECS_SOLUTION_COMPLETE.md](./DATECS_SOLUTION_COMPLETE.md)** ⭐

**The complete technical guide** for the Datecs DP-25MX printer protocol implementation.

**Contents:**
- ✅ **Protocol Specification** - Complete packet structure and format
- ✅ **Checksum Algorithm** - Fully documented and explained
- ✅ **Implementation Guide** - How the code works
- ✅ **Test Results** - Verified with real hardware
- ✅ **Code Examples** - Usage patterns and samples
- ✅ **Troubleshooting** - Known issues and solutions

**Status:** ✅ Complete and tested with real printer hardware

---

## 🎯 For Developers

### Quick Start
1. Read [DATECS_SOLUTION_COMPLETE.md](./DATECS_SOLUTION_COMPLETE.md) for protocol details
2. Check `../datecs_printer_complete.js` for the implementation
3. Review the main [README.md](../README.md) for usage instructions

### Protocol Summary

The Datecs DP-25MX uses a proprietary protocol over TCP/IP:

**Packet Format:**
```
[STX][LENGTH][COMMAND_DATA][ENQ][CHECKSUM][ETX]
```

**Key Details:**
- **Port:** 4999 (standard for Datecs)
- **Protocol:** Binary frames over TCP
- **Checksum:** Sum(LENGTH + COMMAND_DATA) + 0x05
- **Encoding:** ASCII text with binary delimiters

**Working Implementation:**
- Location: `../datecs_printer_complete.js`
- Tested: ✅ Yes, with real DP-25MX hardware
- Status: Fully functional

---

## 📚 Additional Resources

For usage and setup instructions, see the main project [README.md](../README.md).

For questions or issues:
- Check [DATECS_SOLUTION_COMPLETE.md](./DATECS_SOLUTION_COMPLETE.md) first
- Review code in `datecs_printer_complete.js`
- Open an issue on GitHub if needed

---

**Last Updated:** October 2025

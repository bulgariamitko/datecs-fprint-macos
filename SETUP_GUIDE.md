# Datecs FPrint Setup Guide

## Step 1: Find Your Printer Information

Before using the app, you need to gather information about your Datecs fiscal printer:

### Required Information:
1. **IP Address** - The network IP of your printer
2. **Port** - Usually 4999 for TCP/IP communication
3. **Serial Number** - Found in printer settings or on device label
4. **Fiscal Memory Number** - Found in printer information
5. **Device Model** - Your printer model (e.g., DP-25MX, DP-50X, FP-2000)

### How to Find This Information:

#### From Printer Display/Menu:
1. Access printer's service menu
2. Navigate to "Information" or "Device Info"
3. Note down the serial number and fiscal memory number
4. Check the model printed on the device label

#### From Network:
1. Check your printer's network settings
2. Note the IP address (usually 192.168.x.x)
3. Default port is typically 4999

#### Example Values:
- **IP Address**: 192.168.1.100
- **Port**: 4999
- **Model**: DP-25MX
- **Serial Number**: AB123456
- **Fiscal Memory**: 12345678

## Step 2: First Run Configuration

1. Launch DatecsFPrint.app
2. You'll see a "Welcome" screen for first-time setup
3. Click "Open Settings"
4. Fill in all the required fields with your printer information
5. Click "Save"

## Step 3: Test Connection

1. In the main app window, click "Test Connection"
2. You should see "Connection test successful" in the log
3. If it fails, check:
   - IP address is correct
   - Printer is powered on
   - Network connection is working
   - Port 4999 is accessible

## Step 4: Quick Test

Use the provided test script to verify connection:

```bash
python3 simple_tcp_test.py YOUR_PRINTER_IP 4999
```

Replace `YOUR_PRINTER_IP` with your actual printer IP address.

## Supported Datecs Models

This application works with Datecs fiscal printers that support TCP/IP communication:

- **DP-25MX** (Primary tested model)
- **DP-50X** series
- **FP-2000** series
- **Other Datecs models** with Ethernet/WiFi connectivity

## Common Issues

### Connection Failed
- Check if printer is powered on
- Verify IP address and port
- Ensure printer is on the same network
- Check firewall settings

### Invalid Response
- Verify serial number is correct
- Check if printer is in fiscal mode
- Ensure correct device model is selected

### File Processing Issues
- Check execution folder path exists
- Verify file permissions
- Ensure command format is correct

## Command Examples

### Basic Device Information:
```
I,1,______,_,__;0;80
```

### Get Last Document Number:
```
N,1,______,_,__;
```

### Open Fiscal Receipt (example):
```
48,1,______,_,__;1;1;1;0;[OPERATOR_CODE];
```

## Support

For issues with the macOS app:
- Check the app logs in the Log Viewer tab
- Verify printer compatibility
- Test connection using the built-in connection tester

For Datecs printer-specific issues:
- Consult your printer's manual
- Contact Datecs technical support
- Check printer firmware version

## File Locations

- **Configuration**: ~/.datecs-settings
- **Logs**: Displayed in the app's Log Viewer tab
- **Electron cache**: ~/Library/Application Support/DatecsFPrint
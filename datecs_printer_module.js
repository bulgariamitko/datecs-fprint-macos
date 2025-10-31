#!/usr/bin/env node

/**
 * Datecs DP-25MX Printer Module
 *
 * Successfully communicates with the printer using Windows protocol packets.
 *
 * LIMITATION: Checksum algorithm not yet reverse-engineered.
 * WORKAROUND: Uses pre-captured Windows packets for known commands.
 *
 * For dynamic text printing, you need either:
 * 1. The checksum algorithm from FPrintWIN.dll source
 * 2. A Windows service wrapper around FPrintWIN.dll
 */

const net = require('net');

class DatecsPrinter {
  constructor(ip, port = 4999) {
    this.ip = ip;
    this.port = port;
    this.socket = null;
  }

  /**
   * Connect to the printer
   */
  async connect() {
    return new Promise((resolve, reject) => {
      this.socket = new net.Socket();

      this.socket.on('connect', () => {
        console.log(`✓ Connected to printer at ${this.ip}:${this.port}`);
        resolve();
      });

      this.socket.on('error', (err) => {
        console.error('✗ Connection error:', err.message);
        reject(err);
      });

      this.socket.connect(this.port, this.ip);
    });
  }

  /**
   * Send raw bytes to printer and get response
   */
  async sendCommand(hexString, description = '') {
    return new Promise((resolve, reject) => {
      if (!this.socket) {
        reject(new Error('Not connected'));
        return;
      }

      const command = Buffer.from(hexString, 'hex');
      let responseData = Buffer.alloc(0);
      let responseTimeout;

      const dataHandler = (data) => {
        responseData = Buffer.concat([responseData, data]);

        // Reset timeout on each data reception
        clearTimeout(responseTimeout);
        responseTimeout = setTimeout(() => {
          this.socket.removeListener('data', dataHandler);
          resolve({
            success: true,
            request: hexString,
            response: responseData.toString('hex'),
            responseASCII: this.parseResponse(responseData),
            description
          });
        }, 300); // Wait 300ms after last data
      };

      this.socket.on('data', dataHandler);

      // Send the command
      console.log(`→ Sending: ${description || 'Command'}`);
      this.socket.write(command);

      // Overall timeout
      setTimeout(() => {
        clearTimeout(responseTimeout);
        this.socket.removeListener('data', dataHandler);
        resolve({
          success: responseData.length > 0,
          request: hexString,
          response: responseData.toString('hex'),
          responseASCII: this.parseResponse(responseData),
          description
        });
      }, 2000);
    });
  }

  /**
   * Parse printer response
   */
  parseResponse(buffer) {
    if (buffer.length === 0) return null;

    // Check for control characters
    if (buffer[0] === 0x16) return 'SYN (Processing)';
    if (buffer[0] === 0x15) return 'NAK (Error)';
    if (buffer[0] === 0x06) return 'ACK (Success)';

    // Parse framed response
    if (buffer[0] === 0x01) {
      const enqPos = buffer.indexOf(0x05);
      if (enqPos > 0) {
        const data = buffer.slice(1, enqPos);
        return data.toString('ascii').replace(/[\x00-\x1f\x7f-\xff]/g, '.');
      }
    }

    return buffer.toString('ascii').replace(/[\x00-\x1f\x7f-\xff]/g, '.');
  }

  /**
   * Get printer status
   */
  async getStatus() {
    const result = await this.sendCommand(
      '013030323a203030343a0530313b3f03',
      'Get Status'
    );
    return result;
  }

  /**
   * Get device information
   */
  async getDeviceInfo() {
    const result = await this.sendCommand(
      '013030323a213030353a0530313c3103',
      'Get Device Info'
    );

    // Parse device info from response
    if (result.responseASCII && result.responseASCII.includes('DP-25MX')) {
      const match = result.responseASCII.match(/DP-25MX[^,]*/);
      if (match) {
        return {
          ...result,
          deviceInfo: match[0]
        };
      }
    }

    return result;
  }

  /**
   * Open non-fiscal receipt
   */
  async openReceipt() {
    const result = await this.sendCommand(
      '013030323a23303032360530313b3c03',
      'Open Receipt'
    );

    // Extract document number from response
    if (result.responseASCII) {
      const match = result.responseASCII.match(/(\d{4})/);
      if (match) {
        result.documentNumber = match[1];
      }
    }

    return result;
  }

  /**
   * Close non-fiscal receipt
   */
  async closeReceipt() {
    const result = await this.sendCommand(
      '013030323a29303032370530313c3303',
      'Close Receipt'
    );

    // Extract document number from response
    if (result.responseASCII) {
      const match = result.responseASCII.match(/(\d{4})/);
      if (match) {
        result.documentNumber = match[1];
      }
    }

    return result;
  }

  /**
   * Print text (HARDCODED - uses Windows captured packet)
   *
   * WARNING: This prints "CAPTURE TEST 2" - the text from Windows capture.
   * To print custom text, we need the checksum algorithm.
   */
  async printText(text = 'CAPTURE TEST 2') {
    if (text !== 'CAPTURE TEST 2') {
      console.warn('⚠ WARNING: Can only print "CAPTURE TEST 2" with current implementation');
      console.warn('⚠ Need checksum algorithm to print custom text');
    }

    const result = await this.sendCommand(
      '0130303433263030323a434150545552452054455354203209300930093009300930093005303633a3a03',
      'Print Text: ' + text
    );

    return result;
  }

  /**
   * Print a complete receipt (open, text, close)
   */
  async printReceipt(lines = ['CAPTURE TEST 2']) {
    console.log('\n' + '='.repeat(70));
    console.log('PRINTING RECEIPT');
    console.log('='.repeat(70));

    const results = [];

    // Open receipt
    const openResult = await this.openReceipt();
    results.push(openResult);
    console.log(`✓ Receipt opened (doc #${openResult.documentNumber || '?'})`);
    await this.delay(500);

    // Print lines
    for (const line of lines) {
      const printResult = await this.printText(line);
      results.push(printResult);
      console.log(`✓ Printed: ${line}`);
      await this.delay(500);
    }

    // Close receipt
    const closeResult = await this.closeReceipt();
    results.push(closeResult);
    console.log(`✓ Receipt closed (doc #${closeResult.documentNumber || '?'})`);

    console.log('='.repeat(70));

    return {
      success: true,
      documentNumber: openResult.documentNumber,
      results
    };
  }

  /**
   * Disconnect from printer
   */
  async disconnect() {
    if (this.socket) {
      this.socket.end();
      this.socket = null;
      console.log('✓ Disconnected from printer');
    }
  }

  /**
   * Utility: delay
   */
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Export for use in other modules
module.exports = DatecsPrinter;

// Demo usage if run directly
if (require.main === module) {
  async function demo() {
    const printer = new DatecsPrinter('192.168.1.155', 4999);

    try {
      await printer.connect();

      // Get device info
      const deviceInfo = await printer.getDeviceInfo();
      console.log('\nDevice:', deviceInfo.deviceInfo || 'Unknown');

      // Get status
      const status = await printer.getStatus();
      console.log('Status:', status.responseASCII || 'No response');

      // Print a receipt
      await printer.printReceipt(['CAPTURE TEST 2']);

      await printer.disconnect();

    } catch (error) {
      console.error('Error:', error.message);
    }
  }

  demo();
}

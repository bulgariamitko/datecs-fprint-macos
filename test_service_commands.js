#!/usr/bin/env node

/**
 * Test Service IN/OUT Commands
 *
 * Safe to test - balances to zero (IN 80, then OUT 80)
 */

const DatecsPrinter = require('./datecs_printer_complete.js');

async function testServiceCommands() {
  console.log('╔════════════════════════════════════════════════════════════════════╗');
  console.log('║           TESTING SERVICE IN/OUT COMMANDS                          ║');
  console.log('╚════════════════════════════════════════════════════════════════════╝');
  console.log('');

  const printer = new DatecsPrinter('192.168.1.155', 4999);

  try {
    // Connect to printer
    console.log('📡 Connecting to printer...');
    await printer.connect();
    console.log('✓ Connected');
    console.log('');

    // Test 1: Service IN (+ money)
    console.log('┌────────────────────────────────────────────────────────────────┐');
    console.log('│ TEST 1: Service IN (+80)                                       │');
    console.log('└────────────────────────────────────────────────────────────────┘');

    const serviceInCommand = buildTextCommand('I,1,______,_,__;0;80');
    console.log('Sending: I,1,______,_,__;0;80 (Service IN)');

    const result1 = await printer.sendCommand(serviceInCommand, 'Service IN');

    if (result1.success) {
      console.log('✅ Service IN command accepted by printer');
    } else {
      console.log('⚠️  Service IN got NAK response');
    }
    console.log('');

    // Wait a bit
    await printer.delay(2000);

    // Test 2: Service OUT (- money) to balance
    console.log('┌────────────────────────────────────────────────────────────────┐');
    console.log('│ TEST 2: Service OUT (-80) - Balancing                          │');
    console.log('└────────────────────────────────────────────────────────────────┘');

    const serviceOutCommand = buildTextCommand('I,1,______,_,__;1;80');
    console.log('Sending: I,1,______,_,__;1;80 (Service OUT)');

    const result2 = await printer.sendCommand(serviceOutCommand, 'Service OUT');

    if (result2.success) {
      console.log('✅ Service OUT command accepted by printer');
    } else {
      console.log('⚠️  Service OUT got NAK response');
    }
    console.log('');

    // Disconnect
    await printer.disconnect();

    // Summary
    console.log('');
    console.log('╔════════════════════════════════════════════════════════════════════╗');
    console.log('║                         TEST COMPLETE                              ║');
    console.log('╚════════════════════════════════════════════════════════════════════╝');
    console.log('');
    console.log('Check your printer receipt to see if:');
    console.log('  1. Service IN (СЛУЖЕБНО ВЪВЕДЕНИ) printed');
    console.log('  2. Service OUT (СЛУЖЕБНО ИЗВЕДЕНИ) printed');
    console.log('  3. Both show 80 amount');
    console.log('  4. Cash balance is zero (balanced transaction)');
    console.log('');

  } catch (error) {
    console.error('');
    console.error('╔════════════════════════════════════════════════════════════════════╗');
    console.error('║                         ❌ TEST FAILED                             ║');
    console.error('╚════════════════════════════════════════════════════════════════════╝');
    console.error('');
    console.error('Error:', error.message);
    console.error('');

    await printer.disconnect();
    process.exit(1);
  }
}

/**
 * Build command using text protocol format
 */
function buildTextCommand(commandText) {
  const STX = 0x01;
  const ENQ = 0x05;
  const ETX = 0x03;

  // Command data: just the text command
  const commandDataStr = commandText;

  // Calculate length: commandData length + 19 (protocol overhead)
  const totalLength = commandDataStr.length + 19;
  const lengthStr = totalLength.toString().padStart(4, '0');

  // Calculate checksum: Sum(LENGTH + COMMAND_DATA) + ENQ
  const fullData = lengthStr + commandDataStr;
  let sum = 0;
  for (let i = 0; i < fullData.length; i++) {
    sum += fullData.charCodeAt(i);
  }
  sum += 0x05; // Add ENQ
  const checksumStr = (sum & 0xFFFF).toString(16).padStart(4, '0');

  // Build packet
  const packet = Buffer.concat([
    Buffer.from([STX]),
    Buffer.from(lengthStr, 'ascii'),
    Buffer.from(commandDataStr, 'ascii'),
    Buffer.from([ENQ]),
    Buffer.from(checksumStr, 'ascii'),
    Buffer.from([ETX])
  ]);

  return packet;
}

// Run the test
testServiceCommands();

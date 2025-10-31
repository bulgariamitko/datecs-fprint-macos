#!/usr/bin/env node

/**
 * Test Service IN/OUT Commands - PROPERLY WRAPPED
 *
 * Using the correct format: &002:COMMAND\t0\t0\t0\t0\t0\t
 */

const DatecsPrinter = require('./datecs_printer_complete.js');

async function testServiceCommands() {
  console.log('╔════════════════════════════════════════════════════════════════════╗');
  console.log('║       TESTING SERVICE IN/OUT (Wrapped Format)                      ║');
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
    console.log('│ TEST 1: Service IN (+80) - WRAPPED                             │');
    console.log('└────────────────────────────────────────────────────────────────┘');

    const serviceInCommand = buildWrappedCommand('I,1,______,_,__;0;80');
    console.log('Sending: &002:I,1,______,_,__;0;80\\t0\\t0\\t0\\t0\\t0\\t');
    console.log('Hex:', serviceInCommand.toString('hex'));

    const result1 = await printer.sendCommand(serviceInCommand, 'Service IN (wrapped)');

    if (result1.success) {
      console.log('✅ Service IN command ACCEPTED!');
    } else {
      console.log('❌ Service IN got NAK response');
    }
    console.log('');

    // Wait a bit
    await printer.delay(3000);

    // Test 2: Service OUT (- money) to balance
    console.log('┌────────────────────────────────────────────────────────────────┐');
    console.log('│ TEST 2: Service OUT (-80) - WRAPPED - Balancing                │');
    console.log('└────────────────────────────────────────────────────────────────┘');

    const serviceOutCommand = buildWrappedCommand('I,1,______,_,__;1;80');
    console.log('Sending: &002:I,1,______,_,__;1;80\\t0\\t0\\t0\\t0\\t0\\t');
    console.log('Hex:', serviceOutCommand.toString('hex'));

    const result2 = await printer.sendCommand(serviceOutCommand, 'Service OUT (wrapped)');

    if (result2.success) {
      console.log('✅ Service OUT command ACCEPTED!');
    } else {
      console.log('❌ Service OUT got NAK response');
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
    console.log('CHECK YOUR PRINTER NOW!');
    console.log('');
    console.log('You should see a receipt with:');
    console.log('  1. Service IN (СЛУЖЕБНО ВЪВЕДЕНИ) - Amount: 80');
    console.log('  2. Service OUT (СЛУЖЕБНО ИЗВЕДЕНИ) - Amount: 80');
    console.log('  3. Net cash movement: 0 (balanced)');
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
 * Build wrapped command using &002:COMMAND\t0\t0\t0\t0\t0\t format
 */
function buildWrappedCommand(commandText) {
  const STX = 0x01;
  const ENQ = 0x05;
  const ETX = 0x03;

  // Wrap command in &002: format with trailing tabs
  const commandDataStr = `&002:${commandText}\t0\t0\t0\t0\t0\t`;

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

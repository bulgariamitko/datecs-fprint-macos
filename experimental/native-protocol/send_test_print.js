#!/usr/bin/env node

/**
 * Simple test print to capture with Wireshark
 * Sends Service IN command while you're capturing
 */

const DatecsPrinter = require('./datecs_printer_complete.js');

async function sendTestPrint() {
  console.log('Sending test command to printer...');
  console.log('(Make sure Wireshark is capturing!)');
  console.log('');

  const printer = new DatecsPrinter('192.168.1.155', 4999);

  try {
    await printer.connect();
    console.log('Connected to printer');

    // Try the wrapped service IN command
    const command = buildWrappedCommand('I,1,______,_,__;0;80');
    console.log('Sending: &002:I,1,______,_,__;0;80\\t0\\t0\\t0\\t0\\t0\\t');

    const result = await printer.sendCommand(command, 'Test Command');

    console.log('Command sent!');
    console.log('Result:', result.success ? 'ACK' : 'NAK');
    console.log('Response hex:', result.response.toString('hex'));

    await printer.disconnect();
    console.log('Disconnected');

  } catch (error) {
    console.error('Error:', error.message);
  }
}

function buildWrappedCommand(commandText) {
  const STX = 0x01;
  const ENQ = 0x05;
  const ETX = 0x03;

  const commandDataStr = `&002:${commandText}\t0\t0\t0\t0\t0\t`;
  const totalLength = commandDataStr.length + 19;
  const lengthStr = totalLength.toString().padStart(4, '0');

  const fullData = lengthStr + commandDataStr;
  let sum = 0;
  for (let i = 0; i < fullData.length; i++) {
    sum += fullData.charCodeAt(i);
  }
  sum += 0x05;
  const checksumStr = (sum & 0xFFFF).toString(16).padStart(4, '0');

  return Buffer.concat([
    Buffer.from([STX]),
    Buffer.from(lengthStr, 'ascii'),
    Buffer.from(commandDataStr, 'ascii'),
    Buffer.from([ENQ]),
    Buffer.from(checksumStr, 'ascii'),
    Buffer.from([ETX])
  ]);
}

sendTestPrint();

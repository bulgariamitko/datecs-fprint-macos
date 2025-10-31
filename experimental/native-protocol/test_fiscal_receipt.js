#!/usr/bin/env node

/**
 * Test Fiscal Receipt Printing
 *
 * This script tests the complete fiscal receipt workflow with the Datecs DP-25MX printer.
 */

const DatecsPrinter = require('./datecs_printer_complete.js');

async function testFiscalReceipt() {
  console.log('╔════════════════════════════════════════════════════════════════════╗');
  console.log('║     DATECS DP-25MX - FISCAL RECEIPT TEST                           ║');
  console.log('╚════════════════════════════════════════════════════════════════════╝');
  console.log('');

  const printer = new DatecsPrinter('192.168.1.155', 4999);

  try {
    // Connect to printer
    console.log('📡 Connecting to printer...');
    await printer.connect();
    console.log('');

    // Test 1: Simple receipt
    console.log('┌────────────────────────────────────────────────────────────────┐');
    console.log('│ TEST 1: Simple Text Receipt                                    │');
    console.log('└────────────────────────────────────────────────────────────────┘');

    await printer.printReceipt([
      'TEST RECEIPT',
      'DatecsFPrint for macOS',
      '------------------------',
      'Item 1: Coffee',
      'Item 2: Tea',
      '------------------------',
      'Total: $5.00',
      '',
      'Thank you!'
    ]);

    console.log('✅ Test 1 completed!');
    console.log('');

    // Wait between tests
    await printer.delay(3000);

    // Test 2: Single line receipt
    console.log('┌────────────────────────────────────────────────────────────────┐');
    console.log('│ TEST 2: Single Line Receipt                                    │');
    console.log('└────────────────────────────────────────────────────────────────┘');

    await printer.printReceipt(['Quick Test Print!']);

    console.log('✅ Test 2 completed!');
    console.log('');

    // Wait between tests
    await printer.delay(3000);

    // Test 3: Multi-line detailed receipt
    console.log('┌────────────────────────────────────────────────────────────────┐');
    console.log('│ TEST 3: Detailed Receipt                                       │');
    console.log('└────────────────────────────────────────────────────────────────┘');

    const date = new Date().toLocaleDateString('en-US');
    const time = new Date().toLocaleTimeString('en-US');

    await printer.printReceipt([
      '============================',
      'DATECS DP-25MX',
      'macOS Integration Test',
      '============================',
      '',
      `Date: ${date}`,
      `Time: ${time}`,
      '',
      'Products:',
      '1. Coffee       $3.00',
      '2. Tea          $2.50',
      '3. Cookie       $1.50',
      '',
      'Subtotal:       $7.00',
      'Tax (10%):      $0.70',
      '----------------------------',
      'TOTAL:          $7.70',
      '',
      'Payment: Cash   $10.00',
      'Change:         $2.30',
      '',
      'Thank you for your purchase!',
      '============================'
    ]);

    console.log('✅ Test 3 completed!');
    console.log('');

    // Disconnect
    await printer.disconnect();

    // Summary
    console.log('');
    console.log('╔════════════════════════════════════════════════════════════════════╗');
    console.log('║                    ✅ ALL TESTS PASSED!                            ║');
    console.log('╚════════════════════════════════════════════════════════════════════╝');
    console.log('');
    console.log('✓ Printer connection: OK');
    console.log('✓ Receipt printing: OK');
    console.log('✓ Multi-line text: OK');
    console.log('');
    console.log('The Datecs DP-25MX printer is working correctly from macOS! 🎉');
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

// Run the test
testFiscalReceipt();

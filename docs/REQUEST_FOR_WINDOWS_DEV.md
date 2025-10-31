# Request for Windows Developer - Packet Captures

## What We Need

Please capture **10 print commands** with Wireshark showing different text. This will help us decode the checksum algorithm.

---

## Step-by-Step Instructions

### 1. Setup Wireshark
- Open Wireshark
- Start capture on your network interface
- Filter: `tcp.port == 4999`

### 2. Create Test Files

Create 10 text files in `C:\temp\` with these exact contents:

**File: `test1.txt`**
```
Y,1,______,_,__;
P,1,______,_,__;Test;;;;;
T,1,______,_,__;
```

**File: `test2.txt`**
```
Y,1,______,_,__;
P,1,______,_,__;A;;;;;
T,1,______,_,__;
```

**File: `test3.txt`**
```
Y,1,______,_,__;
P,1,______,_,__;Hello;;;;;
T,1,______,_,__;
```

**File: `test4.txt`**
```
Y,1,______,_,__;
P,1,______,_,__;12345;;;;;
T,1,______,_,__;
```

**File: `test5.txt`**
```
Y,1,______,_,__;
P,1,______,_,__;X;;;;;
T,1,______,_,__;
```

**File: `test6.txt`**
```
Y,1,______,_,__;
P,1,______,_,__;World;;;;;
T,1,______,_,__;
```

**File: `test7.txt`**
```
Y,1,______,_,__;
P,1,______,_,__;ABC;;;;;
T,1,______,_,__;
```

**File: `test8.txt`**
```
Y,1,______,_,__;
P,1,______,_,__;Receipt;;;;;
T,1,______,_,__;
```

**File: `test9.txt`**
```
Y,1,______,_,__;
P,1,______,_,__;Line1;;;;;
T,1,______,_,__;
```

**File: `test10.txt`**
```
Y,1,______,_,__;
P,1,______,_,__;ABCDEFGHIJ;;;;;
T,1,______,_,__;
```

### 3. Execute Each File

For each file (test1.txt through test10.txt):
1. Execute it using FPrintWIN.exe
2. Wait for printer to finish
3. Printer should print a receipt

### 4. Stop Wireshark

After all 10 files are executed:
1. Stop the capture (Red square button)
2. Save as: `C:\temp\all_tests_capture.pcapng`

### 5. Export Packet Details

**For EACH print command packet** (the one with "002:" in the data):

1. Find the packet that contains the print text (you'll see "Test", "A", "Hello", etc.)
2. Right-click on that packet
3. Copy → ...as a Hex Stream
4. Paste into a text file: `C:\temp\packet_hex_dumps.txt`
5. Add a label like: `=== Test 1: "Test" ===` before each hex dump

### 6. What to Send Back

Send these 2 files:
- `all_tests_capture.pcapng` (the full capture)
- `packet_hex_dumps.txt` (the hex dumps)

---

## Example Format for packet_hex_dumps.txt

```
=== Test 1: "Test" ===
0130303433263030323a5465737409300930093009300930093005XXXXXXXX03

=== Test 2: "A" ===
0130303433263030323a4109300930093009300930093005XXXXXXXX03

=== Test 3: "Hello" ===
0130303433263030323a48656c6c6f09300930093009300930093005XXXXXXXX03

... etc for all 10 tests
```

---

## Important Notes

- Make sure Wireshark filter is active: `tcp.port == 4999`
- Each test should print successfully on the printer
- We only need the **print command packets** (the ones with text data)
- The hex dumps should be continuous (no spaces)

---

## Questions?

If anything is unclear, just:
1. Capture all 10 print operations in Wireshark
2. Save the .pcapng file
3. Send it back

We can extract the hex data ourselves if needed!

---

**Thank you!** This will allow us to complete the macOS printer integration.

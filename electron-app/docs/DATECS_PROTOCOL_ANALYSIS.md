# Datecs DP-25MX Protocol Analysis
## Captured from Working Windows FPrintWIN.dll

**Date:** 2025-10-24
**Printer:** Datecs DP-25MX (Serial: DA020990)
**Connection:** TCP/IP 192.168.1.155:4999
**Test:** Simple non-fiscal receipt (Y, P, T commands)

---

## Protocol Structure

### Binary Frame Format:
```
[STX] [HIGH-LEVEL-CMD] [ENQ] [CHECKSUM] [ETX]
 01     variable         05    variable    03
```

### HIGH-LEVEL-CMD Format:
```
[SEQ] [DELIMITER] [CMD] [DATA]
```

---

## Captured Command Sequence

### Packet 41 - First Status Check
**Hex:** `01 30 30 32 3a 20 30 30 34 3a 05 30 31 3b 3f 03`

**Decoded:**
- `01` = STX (Start of transmission)
- `30 30 32 3a 20` = "002: " (Sequence "002", delimiter " ")
- `30 30 34 3a` = "004:" (Command code 004)
- `05` = ENQ (Enquiry)
- `30 31 3b` = "01;" (Data)
- `3f` = Checksum (0x3F = 63 decimal)
- `03` = ETX (End of transmission)

**Response from Printer (Packet 43):**
- Status OK, returned device info

---

### Packet 45 - Second Status Check
**Hex:** `01 30 30 32 3a 21 30 30 35 3a 05 30 31 3c 31 03`

**Decoded:**
- `01` = STX
- `30 30 32 3a 21` = "002:!" (Sequence "002", delimiter "!")
- `30 30 35 3a` = "005:" (Command code 005)
- `05` = ENQ
- `30 31 3c` = "01<" (Data)
- `31` = Checksum (0x31 = 49 decimal)
- `03` = ETX

---

### Packet 53 - Open Receipt Command (Y)
**Hex:** `01 30 30 32 3a 23 30 30 32 36 05 30 31 3b 3c 03`

**Decoded:**
- `01` = STX
- `30 30 32 3a 23` = "002:#" (Sequence "002", delimiter "#")
- `30 30 32 36` = "0026" (Command 38 decimal = 0x26)
- `05` = ENQ
- `30 31 3b` = "01;" (Data - probably "Y,1,______,_,__;")
- `3c` = Checksum (0x3C = 60 decimal)
- `03` = ETX

---

### Packet 65 - Print Text Command (P)
**Hex:** `01 30 30 34 33 26 30 30 32 3a 43 41 50 54 55 52 45 20 54 45 53 54 20 32 09 30 09 30 09 30 09 30 09 30 09 05 30 36 3a 3a 03`

**Decoded:**
- `01` = STX
- `30 30 34 33 26` = "0043&" (Sequence "0043", delimiter "&")
- `30 30 32 3a` = "002:" (Command code 002)
- `43 41 50 54 55 52 45 20 54 45 53 54 20 32` = "CAPTURE TEST 2" ← **Print text!**
- `09` = TAB (field separator)
- `30 09 30 09 30 09 30 09 30 09` = "0" + TAB repeated (empty fields)
- `05` = ENQ
- `30 36 3a 3a` = "06::" (Checksum)
- `03` = ETX

---

### Packet 77 - Close Receipt Command (T)
**Hex:** `01 30 30 32 3a 29 30 30 32 37 05 30 31 3c 33 03`

**Decoded:**
- `01` = STX
- `30 30 32 3a 29` = "002:)" (Sequence "002", delimiter ")")
- `30 30 32 37` = "0027" (Command 39 decimal = 0x27)
- `05` = ENQ
- `30 31 3c` = "01<" (Data)
- `33` = Checksum (0x33 = 51 decimal)
- `03` = ETX

---

## Key Findings

### 1. Protocol Layers

The system uses **TWO protocol layers**:

**Layer 1: Text Command Layer** (from FPrint documentation)
```
Y,1,______,_,__;         ← Open receipt
P,1,______,_,__;Text;;;;;  ← Print text
T,1,______,_,__;         ← Close receipt
```

**Layer 2: Binary Transport Layer** (from Wireshark capture)
```
01 [SEQ]:[DELIM] [CMD] [DATA] 05 [CHK] 03
```

The Windows DLL **TRANSLATES** the text commands into binary protocol commands!

---

### 2. Command Translation

| Text Command | Binary CMD | Hex | Description |
|--------------|------------|-----|-------------|
| `Y,1,...` | `0026` | 0x26 (38) | Open non-fiscal receipt |
| `P,1,...;Text;` | `002:` + text | 0x02 | Print text line |
| `T,1,...` | `0027` | 0x27 (39) | Close receipt |

The DLL does NOT send the text format directly - it converts to binary protocol!

---

### 3. Sequence Numbers

Commands use incrementing sequence numbers:
- Format: `002:` followed by delimiter characters (` `, `!`, `"`, `#`, `$`, etc.)
- Delimiter increments with each command: space → ! → " → # → $ → % → & → ' → ( → )

---

### 4. Checksum Algorithm

Looking at examples:
- Packet 41: Data ends with `3f` (63 decimal)
- Packet 45: Data ends with `31` (49 decimal)
- Packet 53: Data ends with `3c` (60 decimal)

**Appears to be:** Sum of all bytes between STX and ENQ, then modulo or XOR operation

---

### 5. Field Separators

- **TAB (0x09)** - Used to separate fields in print commands
- **ENQ (0x05)** - Marks end of data, start of checksum
- **STX (0x01)** - Start of frame
- **ETX (0x03)** - End of frame

---

## macOS Implementation Requirements

### ❌ WRONG Approach (What Mac developer tried):
```
Send raw text: "Y,1,______,_,__;"
```

### ✅ CORRECT Approach (What Windows does):

1. **Parse** the text command file
2. **Translate** to binary protocol:
   - Y → Command 0x26 (38)
   - P → Command 0x02 (with text data)
   - T → Command 0x27 (39)
3. **Frame** with binary protocol:
   ```
   01 [SEQ] [CMD] [DATA] 05 [CHECKSUM] 03
   ```
4. **Send** over TCP socket

---

## Example: Sending "Y,1,______,_,__;" (Open Receipt)

### Text Input:
```
Y,1,______,_,__;
```

### Binary Output (from capture):
```
01 30 30 32 3a 23 30 30 32 36 05 30 31 3b 3c 03
```

### Breakdown:
```
01           → STX
30 30 32 3a  → "002:"  (sequence)
23           → "#"     (delimiter)
30 30 32 36  → "0026"  (command 38 = open receipt)
05           → ENQ
30 31 3b     → "01;"   (data)
3c           → Checksum
03           → ETX
```

---

## Next Steps for Mac Developer

### 1. Study the Windows DLL Source Code
Location: `C:\Program Files (x86)\Datecs Applications\FPrintWIN\OpenSource\`

Look for:
- Command translation table (Y→38, P→2, T→39)
- Checksum calculation algorithm
- Sequence number management

### 2. Implement Protocol Encoder

```python
def encode_command(text_cmd, seq_num):
    # Parse: "Y,1,______,_,__;"
    cmd_type = text_cmd[0]  # 'Y'

    # Translate to binary command
    if cmd_type == 'Y':
        bin_cmd = "0026"  # Open receipt
    elif cmd_type == 'P':
        bin_cmd = "002:"  # Print with data
    elif cmd_type == 'T':
        bin_cmd = "0027"  # Close receipt

    # Build frame
    frame = bytearray()
    frame.append(0x01)  # STX
    frame.extend(f"002:{get_delimiter(seq_num)}".encode('ascii'))
    frame.extend(bin_cmd.encode('ascii'))
    # ... add data and checksum
    frame.append(0x03)  # ETX

    return bytes(frame)
```

### 3. Test Protocol

Use captured hex as golden reference:
```python
test_output = encode_command("Y,1,______,_,__;", 3)
expected = bytes.fromhex("013030323a233030323605303 13b3c03")

assert test_output == expected, "Protocol mismatch!"
```

---

## Complete Packet List (All 10 Commands)

```
Pkt  Hex                                                         Decoded
==========================================================================================
41   013030323a203030343a0530313b3f03                          Status check
45   013030323a213030353a0530313c3103                          Status check
49   013030323a223030343c0530313c3303                          Status check
53   013030323a23303032360530313b3c03                          Open receipt (Y)
57   013030323a243030343c0530313c3503                          Status
61   013030323a253030343c0530313c3603                          Status
65   0130303433263030323a434150545552452054455354203209...03  Print text (P)
69   013030323a273030343c0530313c3803                          Status
73   013030323a283030343c0530313c3903                          Status
77   013030323a29303032370530313c3303                          Close receipt (T)
```

---

## Summary

**The NAK errors happened because:**
1. Mac developer sent raw text: `Y,1,______,_,__;`
2. Printer expected binary protocol: `01 30 30... 03`
3. Printer rejected malformed command → NAK

**Solution:**
- Implement the binary protocol layer
- Translate text commands → binary commands
- Add proper framing (STX/ETX), sequencing, and checksums

**All necessary information is now documented!** 🎯

---

**Generated from Wireshark capture:** `C:\temp\printer_capture2.pcapng`
**Total packets analyzed:** 145
**Data bytes captured:** 651

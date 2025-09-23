#!/usr/bin/env swift

import Foundation
import Network

// Quick test script to verify the core functionality
print("=== Datecs FPrint Quick Test ===")

// Test 1: Check if config file exists
let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
let configURL = documentsPath.appendingPathComponent("DatecsFPrint.config")

print("1. Checking configuration...")
if FileManager.default.fileExists(atPath: configURL.path) {
    print("   ✓ Config file found at: \(configURL.path)")

    // Try to read the config
    do {
        let data = try Data(contentsOf: configURL)
        if let jsonString = String(data: data, encoding: .utf8) {
            print("   ✓ Config file is readable")

            // Parse JSON to check if it has required fields
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let requiredFields = ["ipAddress", "deviceModel", "serialNumber"]
                var missingFields: [String] = []

                for field in requiredFields {
                    if let value = json[field] as? String, !value.isEmpty {
                        print("   ✓ \(field): \(value)")
                    } else {
                        missingFields.append(field)
                    }
                }

                if missingFields.isEmpty {
                    print("   ✓ All required fields are configured")
                } else {
                    print("   ⚠️  Missing fields: \(missingFields.joined(separator: ", "))")
                }
            }
        }
    } catch {
        print("   ✗ Error reading config: \(error)")
    }
} else {
    print("   ℹ️  No config file found - app will show first-time setup")
}

print("\n2. Testing TCP connection capability...")

// Simple network availability test
func testTCPCapability() {
    let semaphore = DispatchSemaphore(value: 0)

    // Test connection to a known service (Google DNS)
    let connection = NWConnection(to: .hostPort(host: "8.8.8.8", port: 53), using: .tcp)

    connection.stateUpdateHandler = { state in
        switch state {
        case .ready:
            print("   ✓ TCP networking is available")
            connection.cancel()
            semaphore.signal()
        case .failed(let error):
            print("   ⚠️  Network issue: \(error)")
            semaphore.signal()
        default:
            break
        }
    }

    connection.start(queue: .global())

    // Wait for result with timeout
    if semaphore.wait(timeout: .now() + 5) == .timedOut {
        print("   ⚠️  Network test timed out")
        connection.cancel()
    }
}

testTCPCapability()

print("\n3. Testing file system access...")

// Test if we can create directories
let testPath = NSHomeDirectory() + "/Desktop/FPrint"
do {
    try FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)
    print("   ✓ Can create directories at: \(testPath)")
} catch {
    print("   ⚠️  Cannot create directories: \(error)")
}

print("\n=== Test Results ===")
print("• Config location: \(configURL.path)")
print("• Test directory: \(testPath)")
print("• Run the app to configure your printer settings")
print("• Use Settings > Test Connection to verify printer connectivity")

print("\n=== Next Steps ===")
print("1. Power on your Datecs printer")
print("2. Note your printer's IP address")
print("3. Run: python3 simple_tcp_test.py YOUR_PRINTER_IP 4999")
print("4. If that works, launch the macOS app and configure settings")
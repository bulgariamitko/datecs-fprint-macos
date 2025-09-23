import Foundation
import SwiftUI

struct FPrintConfiguration: Codable {
    var country: String = ""
    var deviceModel: String = ""
    var communicationType: CommunicationType = .tcp
    var serialPort: String = "/dev/tty.usbserial"
    var baudRate: Int = 115200
    var dataBits: Int = 8
    var parity: Parity = .none
    var stopBits: StopBits = .one
    var ipAddress: String = ""
    var port: Int = 4999
    var serialNumber: String = ""
    var fiscalMemoryNumber: String = ""
    var executableFileName: String = "*.FP"
    var answerFileName: String = "*.ANS"
    var residentMode: Bool = false
    var checkInterval: Int = 1000
    var executionFolderPath: String = NSHomeDirectory() + "/Desktop/FPrint"
    var deleteAfterProcessing: Bool = false
    var moveToExecutedFolder: Bool = true
    var encoding: TextEncoding = .utf8
    var operatorPassword: String = "1"
    var logFolderPath: String = NSHomeDirectory() + "/Desktop/FPrint/Logs"
    var panicModeEnabled: Bool = false
    var showErrorMessages: Bool = true
    var classicalAnswers: Bool = true
    var timeoutSeconds: Int = 10
    var retryCount: Int = 3

    var isConfigured: Bool {
        return !ipAddress.isEmpty && !deviceModel.isEmpty && !serialNumber.isEmpty
    }
}

enum CommunicationType: String, CaseIterable, Codable {
    case tcp = "TCP/IP"
    case serial = "Serial"
}

enum Parity: String, CaseIterable, Codable {
    case none = "None"
    case even = "Even"
    case odd = "Odd"
}

enum StopBits: String, CaseIterable, Codable {
    case one = "1"
    case two = "2"
}

enum TextEncoding: String, CaseIterable, Codable {
    case utf8 = "UTF-8"
    case dosCyrillic = "DOS-Cyrillic"
}

class ConfigurationManager: ObservableObject {
    @Published var config = FPrintConfiguration()
    @Published var isConnected = false

    private let configFileURL: URL

    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        configFileURL = documentsPath.appendingPathComponent("DatecsFPrint.config")
        loadConfiguration()
    }

    func loadConfiguration() {
        do {
            let data = try Data(contentsOf: configFileURL)
            config = try JSONDecoder().decode(FPrintConfiguration.self, from: data)
        } catch {
            print("Could not load configuration: \(error)")
            saveConfiguration()
        }
    }

    func saveConfiguration() {
        do {
            let data = try JSONEncoder().encode(config)
            try data.write(to: configFileURL)
        } catch {
            print("Could not save configuration: \(error)")
        }
    }

    func testConnection() async -> Bool {
        guard config.communicationType == .tcp else {
            return false
        }

        let tcpComm = TCPCommunication(
            host: config.ipAddress,
            port: config.port,
            timeout: TimeInterval(config.timeoutSeconds)
        )

        return await tcpComm.testConnection()
    }

    func createExecutionFolder() {
        let fileManager = FileManager.default
        let executionURL = URL(fileURLWithPath: config.executionFolderPath)
        let logURL = URL(fileURLWithPath: config.logFolderPath)

        try? fileManager.createDirectory(at: executionURL, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: logURL, withIntermediateDirectories: true)

        if config.moveToExecutedFolder {
            let executedURL = executionURL.appendingPathComponent("Executed")
            try? fileManager.createDirectory(at: executedURL, withIntermediateDirectories: true)
        }
    }

    func getAvailableSerialPorts() -> [String] {
        let fileManager = FileManager.default
        do {
            let devContents = try fileManager.contentsOfDirectory(atPath: "/dev")
            return devContents.filter { $0.hasPrefix("tty.") || $0.hasPrefix("cu.") }
                .map { "/dev/\($0)" }
                .sorted()
        } catch {
            return ["/dev/tty.usbserial"]
        }
    }
}
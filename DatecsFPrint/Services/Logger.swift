import Foundation
import SwiftUI

enum LogLevel: String, CaseIterable {
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case debug = "DEBUG"

    var color: Color {
        switch self {
        case .info:
            return .primary
        case .warning:
            return .orange
        case .error:
            return .red
        case .debug:
            return .secondary
        }
    }
}

struct LogEntry: Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let level: LogLevel
    let message: String

    static func == (lhs: LogEntry, rhs: LogEntry) -> Bool {
        return lhs.id == rhs.id
    }
}

class Logger: ObservableObject {
    static let shared = Logger()

    @Published var logs: [LogEntry] = []

    private let maxLogEntries = 1000
    private let logQueue = DispatchQueue(label: "logger.queue", qos: .utility)
    private var logFileURL: URL?

    init() {
        setupLogFile()
    }

    private func setupLogFile() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let logDirectory = documentsPath.appendingPathComponent("Logs")

        do {
            try FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let todayString = dateFormatter.string(from: Date())

            logFileURL = logDirectory.appendingPathComponent("FPrint_log_\(todayString).txt")
        } catch {
            print("Error setting up log file: \(error)")
        }
    }

    func log(_ message: String, level: LogLevel = .info) {
        let entry = LogEntry(timestamp: Date(), level: level, message: message)

        DispatchQueue.main.async {
            self.logs.append(entry)

            // Keep only the most recent entries
            if self.logs.count > self.maxLogEntries {
                self.logs.removeFirst(self.logs.count - self.maxLogEntries)
            }
        }

        // Write to file asynchronously
        logQueue.async {
            self.writeToFile(entry: entry)
        }
    }

    private func writeToFile(entry: LogEntry) {
        guard let logFileURL = logFileURL else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestampString = dateFormatter.string(from: entry.timestamp)

        let logLine = "[\(timestampString)] [\(entry.level.rawValue)] \(entry.message)\n"

        do {
            if FileManager.default.fileExists(atPath: logFileURL.path) {
                // Append to existing file
                let fileHandle = try FileHandle(forWritingTo: logFileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(logLine.data(using: .utf8) ?? Data())
                fileHandle.closeFile()
            } else {
                // Create new file
                try logLine.write(to: logFileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Error writing to log file: \(error)")
        }
    }

    func clearLogs() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
    }

    func exportLogs() -> URL? {
        guard let logFileURL = logFileURL else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestampString = dateFormatter.string(from: Date())

        let exportURL = logFileURL.deletingLastPathComponent()
            .appendingPathComponent("FPrint_export_\(timestampString).txt")

        do {
            let allLogs = logs.map { entry in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let timestampString = dateFormatter.string(from: entry.timestamp)
                return "[\(timestampString)] [\(entry.level.rawValue)] \(entry.message)"
            }.joined(separator: "\n")

            try allLogs.write(to: exportURL, atomically: true, encoding: .utf8)
            return exportURL
        } catch {
            log("Error exporting logs: \(error)", level: .error)
            return nil
        }
    }

    // MARK: - Legacy FPrint.log compatibility

    func logToFPrintFile(_ message: String, logFolderPath: String? = nil) {
        let logPath: String
        if let customPath = logFolderPath {
            logPath = (customPath as NSString).appendingPathComponent("FPrint_log.txt")
        } else {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            logPath = documentsPath.appendingPathComponent("FPrint_log.txt").path
        }

        let timestamp = DateFormatter.fprintTimestamp.string(from: Date())
        let logLine = "[\(timestamp)] \(message)\n"

        do {
            // Create directory if needed
            let logURL = URL(fileURLWithPath: logPath)
            let logDirectory = logURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)

            if FileManager.default.fileExists(atPath: logPath) {
                // Append to existing file
                let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: logPath))
                fileHandle.seekToEndOfFile()
                fileHandle.write(logLine.data(using: .utf8) ?? Data())
                fileHandle.closeFile()
            } else {
                // Create new file
                try logLine.write(toFile: logPath, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Error writing to FPrint log file: \(error)")
        }
    }

    // MARK: - Debug helpers

    func logCommand(_ command: String, direction: String) {
        log("\(direction): \(command)", level: .debug)
    }

    func logError(_ error: Error, context: String = "") {
        let message = context.isEmpty ? error.localizedDescription : "\(context): \(error.localizedDescription)"
        log(message, level: .error)
    }

    func logConnectionEvent(_ event: String, success: Bool) {
        let level: LogLevel = success ? .info : .error
        let status = success ? "SUCCESS" : "FAILED"
        log("Connection \(event): \(status)", level: level)
    }

    func logFileOperation(_ operation: String, path: String, success: Bool) {
        let level: LogLevel = success ? .info : .error
        let status = success ? "SUCCESS" : "FAILED"
        log("File \(operation) (\(path)): \(status)", level: level)
    }
}

extension DateFormatter {
    static let fprintTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return formatter
    }()
}
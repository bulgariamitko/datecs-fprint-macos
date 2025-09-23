import Foundation

struct FPrintCommand {
    let command: String
    let logicNumber: String
    let serviceField: String
    let parameters: [String]
    let originalLine: String

    static func parse(_ line: String) -> FPrintCommand? {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLine.isEmpty else { return nil }

        let parts = trimmedLine.components(separatedBy: ";")
        guard parts.count >= 1 else { return nil }

        let commandPart = parts[0]
        let commandComponents = commandPart.components(separatedBy: ",")

        guard commandComponents.count >= 3 else { return nil }

        let command = commandComponents[0]
        let logicNumber = commandComponents.count > 1 ? commandComponents[1] : "1"
        let serviceField = commandComponents.count > 2 ? commandComponents[2] : "______,_,__"

        let parameters = Array(parts.dropFirst())

        return FPrintCommand(
            command: command,
            logicNumber: logicNumber,
            serviceField: serviceField,
            parameters: parameters,
            originalLine: trimmedLine
        )
    }

    func toCommandString() -> String {
        let baseCommand = "\(command),\(logicNumber),\(serviceField)"
        if parameters.isEmpty {
            return baseCommand + ";"
        } else {
            return baseCommand + ";" + parameters.joined(separator: ";") + ";"
        }
    }
}

struct FPrintResponse {
    let command: String
    let logicNumber: String
    let serviceField: String
    let responseData: [String]
    let originalParameters: [String]
    let errorCode: Int?
    let originalLine: String

    static func parse(_ line: String, originalCommand: FPrintCommand? = nil) -> FPrintResponse? {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLine.isEmpty else { return nil }

        if let errorCode = Int(trimmedLine), errorCode > 0 {
            return FPrintResponse(
                command: originalCommand?.command ?? "",
                logicNumber: originalCommand?.logicNumber ?? "",
                serviceField: originalCommand?.serviceField ?? "",
                responseData: [],
                originalParameters: originalCommand?.parameters ?? [],
                errorCode: errorCode,
                originalLine: trimmedLine
            )
        }

        let parts = trimmedLine.components(separatedBy: ";")
        guard parts.count >= 1 else { return nil }

        let commandPart = parts[0]
        let commandComponents = commandPart.components(separatedBy: ",")

        guard commandComponents.count >= 3 else { return nil }

        let command = commandComponents[0]
        let logicNumber = commandComponents.count > 1 ? commandComponents[1] : "1"
        let serviceField = commandComponents.count > 2 ? commandComponents[2] : "______,_,__"

        var responseData: [String] = []
        var originalParameters: [String] = []

        if parts.count > 1 {
            let dataParts = Array(parts.dropFirst())
            let responseEndIndex = dataParts.firstIndex(where: { _ in
                originalCommand != nil
            }) ?? dataParts.count

            responseData = Array(dataParts.prefix(responseEndIndex))

            if let originalCmd = originalCommand {
                originalParameters = originalCmd.parameters
            }
        }

        return FPrintResponse(
            command: command,
            logicNumber: logicNumber,
            serviceField: serviceField,
            responseData: responseData,
            originalParameters: originalParameters,
            errorCode: nil,
            originalLine: trimmedLine
        )
    }

    var isError: Bool {
        return errorCode != nil && errorCode! > 0
    }

    func getErrorMessage() -> String? {
        guard let errorCode = errorCode else { return nil }
        return FPrintErrorCodes.getMessage(for: errorCode)
    }
}

class CommandProcessor {
    private let configManager: ConfigurationManager
    private let logger: Logger
    private var tcpCommunication: TCPCommunication?
    private let processingQueue = DispatchQueue(label: "command.processing", qos: .userInitiated)

    init(configManager: ConfigurationManager, logger: Logger) {
        self.configManager = configManager
        self.logger = logger
    }

    private func setupCommunication() -> Bool {
        if configManager.config.communicationType == .tcp {
            tcpCommunication = TCPCommunication(
                host: configManager.config.ipAddress,
                port: configManager.config.port,
                timeout: TimeInterval(configManager.config.timeoutSeconds)
            )
            return true
        } else {
            logger.log("Serial communication not yet implemented", level: .error)
            return false
        }
    }

    func sendTestCommand(_ commandString: String) async -> Bool {
        guard setupCommunication() else { return false }

        guard let command = FPrintCommand.parse(commandString) else {
            logger.log("Invalid command format: \(commandString)", level: .error)
            return false
        }

        logger.log("Sending test command: \(command.command)")

        guard let response = await tcpCommunication?.sendCommand(command.toCommandString()) else {
            logger.log("No response received", level: .error)
            return false
        }

        logger.log("Response: \(response)")

        if let parsedResponse = FPrintResponse.parse(response, originalCommand: command) {
            if parsedResponse.isError {
                logger.log("Error response: \(parsedResponse.getErrorMessage() ?? "Unknown error")", level: .error)
                return false
            }
        }

        return true
    }

    func processFile(path: String) async {
        logger.log("Processing file: \(path)")

        guard FileManager.default.fileExists(atPath: path) else {
            logger.log("File not found: \(path)", level: .error)
            return
        }

        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

            await processCommands(lines, sourceFile: path)

            if configManager.config.moveToExecutedFolder {
                moveToExecutedFolder(path: path)
            } else if configManager.config.deleteAfterProcessing {
                try? FileManager.default.removeItem(atPath: path)
            }

        } catch {
            logger.log("Error reading file \(path): \(error)", level: .error)
        }
    }

    func processSingleFile(path: String, port: String, baud: String, serialNumber: String? = nil, showErrors: Bool = true) async {
        logger.log("Processing single file: \(path)")

        guard FileManager.default.fileExists(atPath: path) else {
            logger.log("File not found: \(path)", level: .error)
            return
        }

        configManager.config.ipAddress = port
        if let portNum = Int(baud) {
            configManager.config.port = portNum
        }
        configManager.config.showErrorMessages = showErrors

        await processFile(path: path)
    }

    private func processCommands(_ commands: [String], sourceFile: String) async {
        guard setupCommunication() else {
            logger.log("Failed to setup communication", level: .error)
            return
        }

        var responses: [String] = []

        for (index, commandLine) in commands.enumerated() {
            guard let command = FPrintCommand.parse(commandLine) else {
                logger.log("Invalid command at line \(index + 1): \(commandLine)", level: .error)
                continue
            }

            logger.log("Sending command \(index + 1)/\(commands.count): \(command.command)")

            var attempt = 0
            var success = false

            while attempt < configManager.config.retryCount && !success {
                attempt += 1

                if let response = await tcpCommunication?.sendCommand(command.toCommandString()) {
                    responses.append(response)

                    if let parsedResponse = FPrintResponse.parse(response, originalCommand: command) {
                        if parsedResponse.isError {
                            let errorMsg = parsedResponse.getErrorMessage() ?? "Unknown error"
                            logger.log("Error in command \(command.command): \(errorMsg)", level: .error)

                            if configManager.config.showErrorMessages {
                                await showErrorMessage("Command \(command.command) failed: \(errorMsg)")
                            }
                        } else {
                            success = true
                            logger.log("Command \(command.command) completed successfully")
                        }
                    } else {
                        success = true
                        logger.log("Command \(command.command) completed")
                    }
                } else {
                    logger.log("No response for command \(command.command) (attempt \(attempt))", level: .error)
                }

                if !success && attempt < configManager.config.retryCount {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }
            }

            if !success {
                logger.log("Command \(command.command) failed after \(configManager.config.retryCount) attempts", level: .error)
            }
        }

        await writeAnswerFile(responses: responses, sourceFile: sourceFile)
    }

    private func writeAnswerFile(responses: [String], sourceFile: String) async {
        guard !responses.isEmpty else { return }

        let sourceURL = URL(fileURLWithPath: sourceFile)
        let fileName = sourceURL.deletingPathExtension().lastPathComponent

        let answerFileName: String
        if configManager.config.answerFileName.contains("*") {
            answerFileName = configManager.config.answerFileName.replacingOccurrences(of: "*", with: fileName)
        } else {
            let timestamp = DateFormatter.fileTimestamp.string(from: Date())
            answerFileName = "\(fileName)_\(timestamp).ANS"
        }

        let answerPath = sourceURL.deletingLastPathComponent().appendingPathComponent(answerFileName).path

        let content = responses.joined(separator: "\r\n") + "\r\n"

        do {
            try content.write(toFile: answerPath, atomically: true, encoding: .utf8)
            logger.log("Answer file written: \(answerFileName)")
        } catch {
            logger.log("Error writing answer file: \(error)", level: .error)
        }
    }

    private func moveToExecutedFolder(path: String) {
        let sourceURL = URL(fileURLWithPath: path)
        let executedFolderURL = sourceURL.deletingLastPathComponent().appendingPathComponent("Executed")

        do {
            try FileManager.default.createDirectory(at: executedFolderURL, withIntermediateDirectories: true)

            let timestamp = DateFormatter.fileTimestamp.string(from: Date())
            let fileName = sourceURL.deletingPathExtension().lastPathComponent
            let fileExtension = sourceURL.pathExtension
            let newFileName = "\(fileName)_\(timestamp).\(fileExtension)"

            let destinationURL = executedFolderURL.appendingPathComponent(newFileName)
            try FileManager.default.moveItem(at: sourceURL, to: destinationURL)

            logger.log("File moved to executed folder: \(newFileName)")
        } catch {
            logger.log("Error moving file to executed folder: \(error)", level: .error)
        }
    }

    @MainActor
    private func showErrorMessage(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "FPrint Error"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

struct FPrintErrorCodes {
    static let messages: [Int: String] = [
        0: "OK",
        1: "Communication error",
        2: "Write error - Command is not allowed in current fiscal state",
        3: "Cannot open communication port",
        4: "Error in parameter or command",
        5: "Syntax error",
        6: "File does not exist",
        7: "File access error",
        8: "Hardware fault",
        9: "Fiscal printer is not responding",
        10: "Insufficient paper",
        11: "Insufficient memory",
        12: "Fiscal memory read error",
        13: "Fiscal memory write error",
        14: "Clock not set",
        15: "Missing external display",
        16: "Fiscal printer already activated",
        17: "Fiscal printer not activated",
        18: "Operator password not set",
        19: "Operator not registered",
        20: "Invalid command for current mode"
    ]

    static func getMessage(for code: Int) -> String {
        return messages[code] ?? "Unknown error (\(code))"
    }
}

extension DateFormatter {
    static let fileTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()
}
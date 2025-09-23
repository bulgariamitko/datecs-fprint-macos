import Foundation
import Network

class TCPCommunication {
    private let host: String
    private let port: Int
    private let timeout: TimeInterval
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "tcp.communication", qos: .userInitiated)

    init(host: String, port: Int, timeout: TimeInterval = 10.0) {
        self.host = host
        self.port = port
        self.timeout = timeout
    }

    deinit {
        disconnect()
    }

    func connect() async -> Bool {
        return await withCheckedContinuation { continuation in
            guard let portNumber = NWEndpoint.Port(rawValue: UInt16(port)) else {
                continuation.resume(returning: false)
                return
            }

            let endpoint = NWEndpoint.host(NWEndpoint.Host(host), port: portNumber)
            connection = NWConnection(to: endpoint, using: .tcp)

            connection?.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    continuation.resume(returning: true)
                case .failed(let error):
                    print("Connection failed: \(error)")
                    continuation.resume(returning: false)
                case .cancelled:
                    continuation.resume(returning: false)
                default:
                    break
                }
            }

            connection?.start(queue: queue)

            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                if self.connection?.state != .ready {
                    self.connection?.cancel()
                    continuation.resume(returning: false)
                }
            }
        }
    }

    func disconnect() {
        connection?.cancel()
        connection = nil
    }

    func sendCommand(_ command: String) async -> String? {
        guard let connection = connection, connection.state == .ready else {
            if !(await connect()) {
                return nil
            }
        }

        let commandData = command.data(using: .utf8) ?? Data()
        let commandWithTerminator = commandData + Data([0x0D, 0x0A])

        return await withCheckedContinuation { continuation in
            connection?.send(content: commandWithTerminator, completion: .contentProcessed { error in
                if let error = error {
                    print("Send error: \(error)")
                    continuation.resume(returning: nil)
                    return
                }

                self.receiveResponse { response in
                    continuation.resume(returning: response)
                }
            })
        }
    }

    private func receiveResponse(completion: @escaping (String?) -> Void) {
        guard let connection = connection else {
            completion(nil)
            return
        }

        var receivedData = Data()
        let startTime = Date()

        func receiveNextChunk() {
            connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, isComplete, error in
                if let error = error {
                    print("Receive error: \(error)")
                    completion(nil)
                    return
                }

                if let data = data {
                    receivedData.append(data)

                    if receivedData.contains(0x0D) || receivedData.contains(0x0A) {
                        if let response = String(data: receivedData, encoding: .utf8) {
                            let trimmedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
                            completion(trimmedResponse)
                            return
                        }
                    }
                }

                if isComplete {
                    if let response = String(data: receivedData, encoding: .utf8) {
                        completion(response.trimmingCharacters(in: .whitespacesAndNewlines))
                    } else {
                        completion(nil)
                    }
                    return
                }

                if Date().timeIntervalSince(startTime) > self.timeout {
                    completion(nil)
                    return
                }

                receiveNextChunk()
            }
        }

        receiveNextChunk()
    }

    func testConnection() async -> Bool {
        let connected = await connect()
        if connected {
            disconnect()
        }
        return connected
    }

    func sendRawCommand(_ command: String, encoding: String.Encoding = .utf8) async -> Data? {
        guard let connection = connection, connection.state == .ready else {
            if !(await connect()) {
                return nil
            }
        }

        let commandData = command.data(using: encoding) ?? Data()
        let commandWithTerminator = commandData + Data([0x0D, 0x0A])

        return await withCheckedContinuation { continuation in
            connection?.send(content: commandWithTerminator, completion: .contentProcessed { error in
                if let error = error {
                    print("Send error: \(error)")
                    continuation.resume(returning: nil)
                    return
                }

                self.receiveRawResponse { data in
                    continuation.resume(returning: data)
                }
            })
        }
    }

    private func receiveRawResponse(completion: @escaping (Data?) -> Void) {
        guard let connection = connection else {
            completion(nil)
            return
        }

        var receivedData = Data()
        let startTime = Date()

        func receiveNextChunk() {
            connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, isComplete, error in
                if let error = error {
                    print("Receive error: \(error)")
                    completion(nil)
                    return
                }

                if let data = data {
                    receivedData.append(data)

                    if receivedData.contains(0x0D) || receivedData.contains(0x0A) {
                        completion(receivedData)
                        return
                    }
                }

                if isComplete {
                    completion(receivedData)
                    return
                }

                if Date().timeIntervalSince(startTime) > self.timeout {
                    completion(nil)
                    return
                }

                receiveNextChunk()
            }
        }

        receiveNextChunk()
    }
}
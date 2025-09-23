import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var configManager: ConfigurationManager
    @Environment(\.dismiss) private var dismiss
    @State private var availableSerialPorts: [String] = []

    var body: some View {
        NavigationView {
            Form {
                Section("Device Configuration") {
                    HStack {
                        Text("Country:")
                        Spacer()
                        TextField("e.g., Bulgaria", text: $configManager.config.country)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)
                    }

                    HStack {
                        Text("Device Model:")
                        Spacer()
                        TextField("e.g., DP-25MX, DP-50X, FP-2000", text: $configManager.config.deviceModel)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)
                    }

                    HStack {
                        Text("Serial Number:")
                        Spacer()
                        TextField("From printer info (e.g., AB123456)", text: $configManager.config.serialNumber)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)
                    }

                    HStack {
                        Text("Fiscal Memory:")
                        Spacer()
                        TextField("From printer info (e.g., 12345678)", text: $configManager.config.fiscalMemoryNumber)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)
                    }
                }

                Section("Communication") {
                    Picker("Type:", selection: $configManager.config.communicationType) {
                        ForEach(CommunicationType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    if configManager.config.communicationType == .tcp {
                        TCPSettingsView()
                    } else {
                        SerialSettingsView(availablePorts: availableSerialPorts)
                    }
                }

                Section("File Processing") {
                    FileProcessingSettingsView()
                }

                Section("Advanced") {
                    AdvancedSettingsView()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        configManager.saveConfiguration()
                        configManager.createExecutionFolder()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(width: 600, height: 700)
        .onAppear {
            availableSerialPorts = configManager.getAvailableSerialPorts()
        }
    }
}

struct TCPSettingsView: View {
    @EnvironmentObject var configManager: ConfigurationManager
    @State private var testingConnection = false

    var body: some View {
        HStack {
            Text("IP Address:")
            Spacer()
            TextField("e.g., 192.168.1.100", text: $configManager.config.ipAddress)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
        }

        HStack {
            Text("Port:")
            Spacer()
            TextField("4999", value: $configManager.config.port, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
        }

        HStack {
            Button("Test Connection") {
                Task {
                    testingConnection = true
                    let success = await configManager.testConnection()
                    testingConnection = false
                    configManager.isConnected = success
                }
            }
            .disabled(testingConnection)

            if testingConnection {
                ProgressView()
                    .scaleEffect(0.7)
            }

            Spacer()

            if configManager.isConnected {
                Label("Connected", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
}

struct SerialSettingsView: View {
    @EnvironmentObject var configManager: ConfigurationManager
    let availablePorts: [String]

    var body: some View {
        HStack {
            Text("Port:")
            Spacer()
            Picker("Port", selection: $configManager.config.serialPort) {
                ForEach(availablePorts, id: \.self) { port in
                    Text(port).tag(port)
                }
            }
            .frame(width: 200)
        }

        HStack {
            Text("Baud Rate:")
            Spacer()
            Picker("Baud Rate", selection: $configManager.config.baudRate) {
                ForEach([9600, 19200, 38400, 57600, 115200], id: \.self) { rate in
                    Text("\(rate)").tag(rate)
                }
            }
            .frame(width: 120)
        }

        HStack {
            Text("Data Bits:")
            Spacer()
            Picker("Data Bits", selection: $configManager.config.dataBits) {
                ForEach([7, 8], id: \.self) { bits in
                    Text("\(bits)").tag(bits)
                }
            }
            .frame(width: 80)
        }

        HStack {
            Text("Parity:")
            Spacer()
            Picker("Parity", selection: $configManager.config.parity) {
                ForEach(Parity.allCases, id: \.self) { parity in
                    Text(parity.rawValue).tag(parity)
                }
            }
            .frame(width: 100)
        }

        HStack {
            Text("Stop Bits:")
            Spacer()
            Picker("Stop Bits", selection: $configManager.config.stopBits) {
                ForEach(StopBits.allCases, id: \.self) { bits in
                    Text(bits.rawValue).tag(bits)
                }
            }
            .frame(width: 80)
        }
    }
}

struct FileProcessingSettingsView: View {
    @EnvironmentObject var configManager: ConfigurationManager

    var body: some View {
        HStack {
            Text("Execution Folder:")
            Spacer()
            TextField("Path", text: $configManager.config.executionFolderPath)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)

            Button("Choose") {
                chooseFolder { url in
                    configManager.config.executionFolderPath = url.path
                }
            }
        }

        HStack {
            Text("Executable File Pattern:")
            Spacer()
            TextField("*.FP", text: $configManager.config.executableFileName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
        }

        HStack {
            Text("Answer File Pattern:")
            Spacer()
            TextField("*.ANS", text: $configManager.config.answerFileName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
        }

        HStack {
            Text("Check Interval (ms):")
            Spacer()
            TextField("1000", value: $configManager.config.checkInterval, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
        }

        Toggle("Move to Executed Folder", isOn: $configManager.config.moveToExecutedFolder)

        Toggle("Delete After Processing", isOn: $configManager.config.deleteAfterProcessing)

        HStack {
            Text("Encoding:")
            Spacer()
            Picker("Encoding", selection: $configManager.config.encoding) {
                ForEach(TextEncoding.allCases, id: \.self) { encoding in
                    Text(encoding.rawValue).tag(encoding)
                }
            }
            .frame(width: 150)
        }
    }

    private func chooseFolder(completion: @escaping (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            completion(url)
        }
    }
}

struct AdvancedSettingsView: View {
    @EnvironmentObject var configManager: ConfigurationManager

    var body: some View {
        HStack {
            Text("Operator Password:")
            Spacer()
            SecureField("Password", text: $configManager.config.operatorPassword)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
        }

        HStack {
            Text("Timeout (seconds):")
            Spacer()
            TextField("10", value: $configManager.config.timeoutSeconds, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
        }

        HStack {
            Text("Retry Count:")
            Spacer()
            TextField("3", value: $configManager.config.retryCount, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
        }

        Toggle("Show Error Messages", isOn: $configManager.config.showErrorMessages)

        Toggle("Classical Answers", isOn: $configManager.config.classicalAnswers)

        Toggle("Panic Mode", isOn: $configManager.config.panicModeEnabled)

        HStack {
            Text("Log Folder:")
            Spacer()
            TextField("Path", text: $configManager.config.logFolderPath)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)

            Button("Choose") {
                chooseFolder { url in
                    configManager.config.logFolderPath = url.path
                }
            }
        }
    }

    private func chooseFolder(completion: @escaping (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            completion(url)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ConfigurationManager())
}
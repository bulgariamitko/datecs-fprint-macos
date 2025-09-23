import SwiftUI

struct ContentView: View {
    @EnvironmentObject var configManager: ConfigurationManager
    @EnvironmentObject var logger: Logger
    @State private var showingSettings = false
    @State private var isResidentMode = false
    @State private var fileWatcher: FileWatcher?
    @State private var commandProcessor: CommandProcessor?

    var body: some View {
        Group {
            if configManager.config.isConfigured {
                MainApplicationView()
            } else {
                FirstTimeSetupView()
            }
        }
        .onAppear {
            commandProcessor = CommandProcessor(
                configManager: configManager,
                logger: logger
            )
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

struct MainApplicationView: View {
    @EnvironmentObject var configManager: ConfigurationManager
    @EnvironmentObject var logger: Logger
    @State private var showingSettings = false
    @State private var isResidentMode = false
    @State private var fileWatcher: FileWatcher?
    @State private var commandProcessor: CommandProcessor?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "printer")
                    .font(.largeTitle)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text("Datecs FPrint")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("macOS Client for Datecs Fiscal Printers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            ConnectionStatusView()

            VStack(spacing: 15) {
                HStack {
                    Button("Settings") {
                        showingSettings = true
                    }
                    .buttonStyle(.bordered)

                    Button("Test Connection") {
                        Task {
                            await testConnection()
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Spacer()
                }

                HStack {
                    Toggle("Resident Mode", isOn: $isResidentMode)
                        .onChange(of: isResidentMode) { newValue in
                            if newValue {
                                startResidentMode()
                            } else {
                                stopResidentMode()
                            }
                        }

                    Spacer()
                }

                if isResidentMode {
                    ResidentModeStatusView()
                }
            }

            LogView()
                .frame(maxHeight: 200)
        }
        .padding()
        .frame(width: 600, height: 500)
        .onAppear {
            commandProcessor = CommandProcessor(
                configManager: configManager,
                logger: logger
            )
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private func testConnection() async {
        guard let processor = commandProcessor else { return }

        logger.log("Testing connection...")

        let testCommand = "I,1,______,_,__;0;80"
        let success = await processor.sendTestCommand(testCommand)

        if success {
            logger.log("Connection test successful")
        } else {
            logger.log("Connection test failed", level: .error)
        }
    }

    private func startResidentMode() {
        guard fileWatcher == nil else { return }

        fileWatcher = FileWatcher(
            watchPath: configManager.config.executionFolderPath,
            filePattern: configManager.config.executableFileName,
            checkInterval: configManager.config.checkInterval
        ) { filePath in
            Task {
                await commandProcessor?.processFile(path: filePath)
            }
        }

        fileWatcher?.startWatching()
        logger.log("Resident mode started - watching \(configManager.config.executionFolderPath)")
    }

    private func stopResidentMode() {
        fileWatcher?.stopWatching()
        fileWatcher = nil
        logger.log("Resident mode stopped")
    }
}

struct ConnectionStatusView: View {
    @EnvironmentObject var configManager: ConfigurationManager

    var body: some View {
        HStack {
            Circle()
                .fill(configManager.isConnected ? .green : .red)
                .frame(width: 10, height: 10)

            Text(configManager.isConnected ? "Connected" : "Disconnected")
                .font(.caption)

            Spacer()

            Text("IP: \(configManager.config.ipAddress):\(configManager.config.port)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ResidentModeStatusView: View {
    @EnvironmentObject var configManager: ConfigurationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Watching: \(configManager.config.executionFolderPath)")
                .font(.caption)
            Text("Pattern: \(configManager.config.executableFileName)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

struct LogView: View {
    @EnvironmentObject var logger: Logger

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Log")
                    .font(.headline)

                Spacer()

                Button("Clear") {
                    logger.clearLogs()
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(logger.logs, id: \.id) { entry in
                        HStack {
                            Text(entry.timestamp, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(entry.message)
                                .font(.caption)
                                .foregroundColor(entry.level == .error ? .red : .primary)

                            Spacer()
                        }
                    }
                }
            }
            .background(Color.gray.opacity(0.05))
            .cornerRadius(4)
        }
    }
}

struct FirstTimeSetupView: View {
    @EnvironmentObject var configManager: ConfigurationManager
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "printer")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)

                Text("Welcome to Datecs FPrint")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("macOS Client for Datecs Fiscal Printers")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 16) {
                Text("First Time Setup")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("To get started, you need to configure your Datecs printer connection. Please enter your printer's details in the settings.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: 400)

                VStack(alignment: .leading, spacing: 8) {
                    Label("IP address and port", systemImage: "network")
                    Label("Printer model (e.g., DP-25MX)", systemImage: "printer")
                    Label("Serial number", systemImage: "number")
                    Label("Fiscal memory number", systemImage: "memorychip")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Button("Open Settings") {
                showingSettings = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Text("After configuration, you can test the connection and start using the application.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(width: 600, height: 500)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ConfigurationManager())
        .environmentObject(Logger.shared)
}
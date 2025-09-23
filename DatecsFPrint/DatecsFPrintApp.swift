import SwiftUI

@main
struct DatecsFPrintApp: App {
    @StateObject private var configManager = ConfigurationManager()
    @StateObject private var logger = Logger.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(configManager)
                .environmentObject(logger)
                .onAppear {
                    handleCommandLineArguments()
                }
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
    }

    private func handleCommandLineArguments() {
        let args = CommandLine.arguments

        if args.count > 1 {
            if args.contains("--cli") || args.count >= 4 {
                Task {
                    await runCLIMode(args: args)
                }
            }
        }
    }

    private func runCLIMode(args: [String]) async {
        guard args.count >= 4 else {
            print("Usage: FPRINT [port] [baud] [input-file] (serial-number) (no-show-errors)")
            exit(1)
        }

        let port = args[1]
        let baud = args[2]
        let inputFile = args[3]
        let serialNumber = args.count > 4 ? args[4] : nil
        let noShowErrors = args.contains("no-show-errors")

        let processor = CommandProcessor(
            configManager: configManager,
            logger: logger
        )

        await processor.processSingleFile(
            path: inputFile,
            port: port,
            baud: baud,
            serialNumber: serialNumber,
            showErrors: !noShowErrors
        )

        exit(0)
    }
}
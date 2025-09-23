import Foundation

class FileWatcher {
    private let watchPath: String
    private let filePattern: String
    private let checkInterval: TimeInterval
    private let onFileFound: (String) -> Void

    private var timer: Timer?
    private var processedFiles: Set<String> = []
    private let queue = DispatchQueue(label: "file.watcher", qos: .utility)

    init(watchPath: String, filePattern: String, checkInterval: Int, onFileFound: @escaping (String) -> Void) {
        self.watchPath = watchPath
        self.filePattern = filePattern
        self.checkInterval = TimeInterval(checkInterval) / 1000.0 // Convert ms to seconds
        self.onFileFound = onFileFound
    }

    deinit {
        stopWatching()
    }

    func startWatching() {
        stopWatching()

        // Create watch directory if it doesn't exist
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: watchPath) {
            try? fileManager.createDirectory(atPath: watchPath, withIntermediateDirectories: true, attributes: nil)
        }

        timer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
            self?.checkForFiles()
        }

        // Initial check
        checkForFiles()
    }

    func stopWatching() {
        timer?.invalidate()
        timer = nil
    }

    private func checkForFiles() {
        queue.async { [weak self] in
            self?.performFileCheck()
        }
    }

    private func performFileCheck() {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: watchPath) else {
            return
        }

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: watchPath)
            let matchingFiles = contents.filter { fileName in
                matchesPattern(fileName: fileName, pattern: filePattern)
            }

            for fileName in matchingFiles {
                let fullPath = (watchPath as NSString).appendingPathComponent(fileName)

                // Check if we've already processed this file
                if !processedFiles.contains(fullPath) {
                    // Check if file is stable (not being written to)
                    if isFileStable(at: fullPath) {
                        processedFiles.insert(fullPath)

                        DispatchQueue.main.async {
                            self.onFileFound(fullPath)
                        }
                    }
                }
            }

            // Clean up processed files that no longer exist
            let existingFiles = Set(matchingFiles.map { (watchPath as NSString).appendingPathComponent($0) })
            processedFiles = processedFiles.intersection(existingFiles)

        } catch {
            print("Error checking directory contents: \(error)")
        }
    }

    private func isFileStable(at path: String) -> Bool {
        let fileManager = FileManager.default

        guard let attributes1 = try? fileManager.attributesOfItem(atPath: path),
              let modDate1 = attributes1[.modificationDate] as? Date else {
            return false
        }

        // Wait a short time and check again
        Thread.sleep(forTimeInterval: 0.1)

        guard let attributes2 = try? fileManager.attributesOfItem(atPath: path),
              let modDate2 = attributes2[.modificationDate] as? Date else {
            return false
        }

        // File is stable if modification date hasn't changed
        return modDate1 == modDate2
    }

    private func matchesPattern(fileName: String, pattern: String) -> Bool {
        // Convert simple wildcard pattern to regex
        let escapedPattern = NSRegularExpression.escapedPattern(for: pattern)
        let regexPattern = escapedPattern.replacingOccurrences(of: "\\*", with: ".*")

        guard let regex = try? NSRegularExpression(pattern: "^" + regexPattern + "$", options: .caseInsensitive) else {
            // Fallback to simple contains check
            return fileName.lowercased().contains(pattern.lowercased().replacingOccurrences(of: "*", with: ""))
        }

        let range = NSRange(location: 0, length: fileName.utf16.count)
        return regex.firstMatch(in: fileName, options: [], range: range) != nil
    }
}

// MARK: - Directory Monitor using FSEvents (more efficient for high-frequency monitoring)

class FSEventFileWatcher {
    private let watchPath: String
    private let filePattern: String
    private let onFileFound: (String) -> Void

    private var eventStream: FSEventStreamRef?
    private var processedFiles: Set<String> = []
    private let queue = DispatchQueue(label: "fs.event.watcher", qos: .utility)

    init(watchPath: String, filePattern: String, onFileFound: @escaping (String) -> Void) {
        self.watchPath = watchPath
        self.filePattern = filePattern
        self.onFileFound = onFileFound
    }

    deinit {
        stopWatching()
    }

    func startWatching() {
        stopWatching()

        // Create watch directory if it doesn't exist
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: watchPath) {
            try? fileManager.createDirectory(atPath: watchPath, withIntermediateDirectories: true, attributes: nil)
        }

        let pathsToWatch = [watchPath] as CFArray
        let callback: FSEventStreamCallback = { (stream, clientCallBackInfo, numEvents, eventPaths, eventFlags, eventIds) in
            guard let info = clientCallBackInfo else { return }
            let watcher = Unmanaged<FSEventFileWatcher>.fromOpaque(info).takeUnretainedValue()
            watcher.handleEvents()
        }

        var context = FSEventStreamContext()
        context.info = Unmanaged.passUnretained(self).toOpaque()

        eventStream = FSEventStreamCreate(
            kCFAllocatorDefault,
            callback,
            &context,
            pathsToWatch,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            1.0, // 1 second latency
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents)
        )

        if let stream = eventStream {
            FSEventStreamSetDispatchQueue(stream, queue)
            FSEventStreamStart(stream)
        }

        // Initial check
        handleEvents()
    }

    func stopWatching() {
        if let stream = eventStream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
            eventStream = nil
        }
    }

    private func handleEvents() {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: watchPath) else {
            return
        }

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: watchPath)
            let matchingFiles = contents.filter { fileName in
                matchesPattern(fileName: fileName, pattern: filePattern)
            }

            for fileName in matchingFiles {
                let fullPath = (watchPath as NSString).appendingPathComponent(fileName)

                // Check if we've already processed this file
                if !processedFiles.contains(fullPath) {
                    // Check if file is stable (not being written to)
                    if isFileStable(at: fullPath) {
                        processedFiles.insert(fullPath)

                        DispatchQueue.main.async {
                            self.onFileFound(fullPath)
                        }
                    }
                }
            }

        } catch {
            print("Error checking directory contents: \(error)")
        }
    }

    private func isFileStable(at path: String) -> Bool {
        let fileManager = FileManager.default

        guard let attributes1 = try? fileManager.attributesOfItem(atPath: path),
              let modDate1 = attributes1[.modificationDate] as? Date else {
            return false
        }

        // Wait a short time and check again
        Thread.sleep(forTimeInterval: 0.1)

        guard let attributes2 = try? fileManager.attributesOfItem(atPath: path),
              let modDate2 = attributes2[.modificationDate] as? Date else {
            return false
        }

        // File is stable if modification date hasn't changed
        return modDate1 == modDate2
    }

    private func matchesPattern(fileName: String, pattern: String) -> Bool {
        // Convert simple wildcard pattern to regex
        let escapedPattern = NSRegularExpression.escapedPattern(for: pattern)
        let regexPattern = escapedPattern.replacingOccurrences(of: "\\*", with: ".*")

        guard let regex = try? NSRegularExpression(pattern: "^" + regexPattern + "$", options: .caseInsensitive) else {
            // Fallback to simple contains check
            return fileName.lowercased().contains(pattern.lowercased().replacingOccurrences(of: "*", with: ""))
        }

        let range = NSRange(location: 0, length: fileName.utf16.count)
        return regex.firstMatch(in: fileName, options: [], range: range) != nil
    }
}
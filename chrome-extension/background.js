
// Debug logging function
function logDebug(message, data = null) {
    const timestamp = new Date().toISOString();
    console.log(`[Kasa Debug ${timestamp}]`, message, data || '');

    // Store debug logs for the popup
    chrome.storage.local.get(['debugLogs'], (result) => {
        const logs = result.debugLogs || [];
        logs.push({ timestamp, message, data });
        // Keep only last 20 logs
        if (logs.length > 20) logs.shift();
        chrome.storage.local.set({ debugLogs: logs });
    });
}

// Handle automatic organization of kasa*.txt files that are downloaded
chrome.downloads.onDeterminingFilename.addListener((downloadItem, suggest) => {
    logDebug('Открито изтегляне', {
        filename: downloadItem.filename,
        url: downloadItem.url,
        referrer: downloadItem.referrer
    });

    // Check if the file matches our pattern (kasa followed by optional numbers and .txt)
    const match = downloadItem.filename.match(/^kasa(\d*)\.txt$/i);

    if (match) {
        logDebug('Името на файла съвпада с шаблона kasa*.txt', { filename: downloadItem.filename });

        // Get the user's preferred folder name from storage
        chrome.storage.sync.get(['folderName'], (result) => {
            const folderPath = result.folderName || 'datecs-fprint-macos/FPrintWIN/execute';
            logDebug('Извлечен път до папка от хранилището', { folderPath });

            // Normalize the path - ensure forward slashes and remove any double slashes
            const normalizedPath = folderPath.replace(/\\/g, '/').replace(/\/+/g, '/').replace(/^\/|\/$/g, '');
            logDebug('Нормализиран път', { normalizedPath });

            const newPath = `${normalizedPath}/${downloadItem.filename}`;
            logDebug('Предлагане на нов път за изтегляне', { newPath });

            suggest({
                filename: newPath,
                conflict_action: 'uniquify',
                conflictAction: 'uniquify'
            });
        });

        return true;
    } else {
        logDebug('Името на файла НЕ съвпада с шаблона kasa*.txt - игнориране', { filename: downloadItem.filename });
    }

    // For non-matching files, don't change anything
    suggest({});
    return true;
});

// Listen for messages from popup (for test downloads)
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'testDownload') {
        logDebug('Заявено тестово изтегляне', { folderPath: request.folderPath });

        // Create a test file content
        const testContent = `Kasa Тестов Файл
Генериран: ${new Date().toLocaleString('bg-BG')}
Конфигурирана папка: ${request.folderPath}

Това е тестов файл за проверка дали разширението Kasa работи правилно.
Ако виждате този файл в Downloads/${request.folderPath}/, значи всичко работи!
`;

        // Create a blob with proper filename hint
        const blob = new Blob([testContent], { type: 'text/plain' });
        const blobUrl = URL.createObjectURL(blob);

        // Create a temporary link element to trigger download with proper filename
        // This is needed because Chrome localizes default filenames in some languages
        const timestamp = Date.now();
        const testFilename = `kasa${timestamp}.txt`;

        logDebug('Опит за изтегляне с blob URL', { filename: testFilename });

        // Send response immediately to prevent port closing
        let responseAlreadySent = false;

        const sendSafeResponse = (data) => {
            if (!responseAlreadySent) {
                responseAlreadySent = true;
                try {
                    sendResponse(data);
                } catch (e) {
                    logDebug('Неуспешно изпращане на отговор', { error: e.message });
                }
            }
        };

        // Set a timeout to send response even if download takes too long
        const timeoutId = setTimeout(() => {
            sendSafeResponse({
                success: false,
                error: 'Изтичане на времето за изтегляне',
                details: 'Изтеглянето отнема твърде много време. Проверете конзолата на service worker за детайли.'
            });
        }, 5000);

        chrome.downloads.download({
            url: blobUrl,
            filename: testFilename,
            saveAs: false,
            conflictAction: 'overwrite'
        }, (downloadId) => {
            clearTimeout(timeoutId);

            if (chrome.runtime.lastError) {
                const error = chrome.runtime.lastError.message;
                logDebug('API за изтегляне върна грешка', {
                    error,
                    downloadId,
                    lastError: JSON.stringify(chrome.runtime.lastError)
                });
                sendSafeResponse({
                    success: false,
                    error,
                    details: 'Chrome блокира изтеглянето. Опитайте да проверите chrome://settings/downloads'
                });
                URL.revokeObjectURL(blobUrl);
            } else if (downloadId) {
                logDebug('Изтеглянето започна успешно', { downloadId });

                // Monitor the download completion
                const changeListener = (delta) => {
                    if (delta.id === downloadId) {
                        if (delta.state && delta.state.current === 'complete') {
                            logDebug('Изтеглянето завърши', { downloadId });
                            chrome.downloads.onChanged.removeListener(changeListener);
                            URL.revokeObjectURL(blobUrl);
                        } else if (delta.error) {
                            logDebug('Грешка при изтегляне по време на трансфер', {
                                downloadId,
                                error: delta.error.current
                            });
                            chrome.downloads.onChanged.removeListener(changeListener);
                            URL.revokeObjectURL(blobUrl);
                        }
                    }
                };
                chrome.downloads.onChanged.addListener(changeListener);

                sendSafeResponse({ success: true, downloadId });
            } else {
                logDebug('Изтеглянето се провали - не е върнат ID', { downloadId });
                sendSafeResponse({
                    success: false,
                    error: 'Не е върнат ID за изтегляне',
                    details: 'API за изтегляне не върна ID'
                });
                URL.revokeObjectURL(blobUrl);
            }
        });

        return true; // Keep channel open for async response
    }

    if (request.action === 'getDebugLogs') {
        chrome.storage.local.get(['debugLogs'], (result) => {
            sendResponse({ logs: result.debugLogs || [] });
        });
        return true;
    }

    if (request.action === 'clearDebugLogs') {
        chrome.storage.local.set({ debugLogs: [] }, () => {
            sendResponse({ success: true });
        });
        return true;
    }
});
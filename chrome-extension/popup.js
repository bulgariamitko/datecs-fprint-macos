document.addEventListener('DOMContentLoaded', function() {
    const folderNameInput = document.getElementById('folderName');
    const saveButton = document.getElementById('saveSettings');
    const testButton = document.getElementById('testDownload');
    const statusDiv = document.getElementById('status');
    const debugInfoDiv = document.getElementById('debugInfo');

    // Load saved settings
    chrome.storage.sync.get(['folderName'], function(result) {
        if (result.folderName) {
            folderNameInput.value = result.folderName;
        } else {
            folderNameInput.value = 'datecs-fprint-macos/FPrintWIN/execute'; // Default folder name
        }
    });

    // Save settings
    saveButton.addEventListener('click', function() {
        const folderName = folderNameInput.value.trim();

        if (!folderName) {
            showStatus('Моля, въведете име на папка', 'error');
            return;
        }

        // Remove invalid characters for folder names, but keep forward slashes for subfolders
        const cleanFolderName = folderName.replace(/[<>:"|?*]/g, '').replace(/\\/g, '/');

        if (cleanFolderName !== folderName) {
            folderNameInput.value = cleanFolderName;
            showStatus('Невалидни знаци премахнати. Настройките са запазени!', 'success');
        }

        chrome.storage.sync.set({
            folderName: cleanFolderName
        }, function() {
            if (cleanFolderName === folderName) {
                showStatus('Настройките са запазени успешно!', 'success');
            }
        });
    });

    // Test download and debug
    testButton.addEventListener('click', function() {
        const folderPath = folderNameInput.value.trim() || 'datecs-fprint-macos/FPrintWIN/execute';

        showStatus('Стартиране на тестово изтегляне...', 'success');
        debugInfoDiv.style.display = 'none';

        // Request test download
        chrome.runtime.sendMessage({
            action: 'testDownload',
            folderPath: folderPath
        }, function(response) {
            if (chrome.runtime.lastError) {
                showStatus('Грешка в комуникацията: ' + chrome.runtime.lastError.message, 'error');
                displayErrorHelp(chrome.runtime.lastError.message);
                return;
            }

            if (response && response.success) {
                showStatus('Тестовият файл е изтеглен! Проверете Downloads/' + folderPath + '/', 'success');

                // Wait a bit then fetch debug logs
                setTimeout(() => {
                    fetchAndDisplayDebugLogs();
                }, 500);
            } else {
                const error = response ? response.error : 'Неизвестна грешка';
                const details = response ? response.details : '';
                showStatus('Изтеглянето се провали: ' + error, 'error');
                displayErrorHelp(error, details);

                // Still fetch logs to see what happened
                setTimeout(() => {
                    fetchAndDisplayDebugLogs();
                }, 500);
            }
        });
    });

    function fetchAndDisplayDebugLogs() {
        chrome.runtime.sendMessage({ action: 'getDebugLogs' }, function(response) {
            if (response && response.logs && response.logs.length > 0) {
                let debugText = '=== ДЕБЪГ ЛОГА ===\n\n';

                response.logs.forEach((log, index) => {
                    const time = new Date(log.timestamp).toLocaleTimeString();
                    debugText += `[${time}] ${log.message}\n`;
                    if (log.data) {
                        debugText += `  Данни: ${JSON.stringify(log.data, null, 2)}\n`;
                    }
                    debugText += '\n';
                });

                debugText += `\nОчаквана локация за изтегляне:\nDownloads/${folderNameInput.value.trim() || 'datecs-fprint-macos/FPrintWIN/execute'}/kasa-test.txt\n\n`;
                debugText += 'Проверете папката Downloads, за да потвърдите местоположението на файла!';

                debugInfoDiv.textContent = debugText;
                debugInfoDiv.style.display = 'block';
            }
        });
    }

    function displayErrorHelp(error, details = '') {
        let helpText = '=== ОТСТРАНЯВАНЕ НА ПРОБЛЕМИ ===\n\n';
        helpText += `Грешка: ${error}\n`;
        if (details) {
            helpText += `Детайли: ${details}\n`;
        }
        helpText += '\n';
        helpText += 'Често срещани решения:\n\n';
        helpText += '1. ПРОВЕРЕТЕ РАЗРЕШЕНИЯТА:\n';
        helpText += '   - Отидете на chrome://extensions/\n';
        helpText += '   - Намерете "Kasa Мениджър за Изтегляния"\n';
        helpText += '   - Уверете се, че всички разрешения са дадени\n\n';
        helpText += '2. ПРОВЕРЕТЕ ПАПКАТА ЗА ИЗТЕГЛЯНИЯ:\n';
        helpText += '   - Отидете на chrome://settings/downloads\n';
        helpText += '   - Уверете се, че имате валидна локация за изтегляне\n';
        helpText += '   - Уверете се, че "Питай къде да се запази всеки файл" е ИЗКЛЮЧЕНО\n\n';
        helpText += '3. ОПИТАЙТЕ ПО-ПРОСТ ПЪТ:\n';
        helpText += '   - Опитайте да използвате само "KasaFiles" вместо вложени пътища\n';
        helpText += '   - Специалните знаци може да причинят проблеми\n\n';
        helpText += '4. ПРЕЗАРЕДЕТЕ РАЗШИРЕНИЕТО:\n';
        helpText += '   - Отидете на chrome://extensions/\n';
        helpText += '   - Натиснете бутона за презареждане на това разширение\n\n';
        helpText += '5. ПРОВЕРЕТЕ КОНЗОЛАТА:\n';
        helpText += '   - Отидете на chrome://extensions/\n';
        helpText += '   - Натиснете линка "service worker" на това разширение\n';
        helpText += '   - Потърсете съобщения за грешки в конзолата\n';

        debugInfoDiv.textContent = helpText;
        debugInfoDiv.style.display = 'block';
    }

    function showStatus(message, type) {
        statusDiv.textContent = message;
        statusDiv.className = `status ${type}`;
        statusDiv.style.display = 'block';

        setTimeout(() => {
            statusDiv.style.display = 'none';
        }, 3000);
    }
});
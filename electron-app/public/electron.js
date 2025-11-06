const { app, BrowserWindow, Menu, ipcMain, dialog } = require('electron');
const path = require('path');
const isDev = process.env.ELECTRON_IS_DEV === 'true';
const fs = require('fs-extra');
const net = require('net');
const os = require('os');
const chokidar = require('chokidar');

let mainWindow;
let fileWatcher = null;
let isResidentModeActive = false;
let currentConfig = null;

function createWindow() {
  // Create the browser window
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
      enableRemoteModule: true
    },
    icon: path.join(__dirname, 'icon.png'),
    titleBarStyle: 'default',
    show: false
  });

  // Load the app
  const startUrl = isDev ? 'http://localhost:3000' : `file://${path.join(__dirname, '../build/index.html')}`;
  mainWindow.loadURL(startUrl);

  // Show window when ready
  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
  });

  // Open DevTools in development
  if (isDev) {
    mainWindow.webContents.openDevTools();
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

// App event handlers
app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

// File watching functionality for resident mode
async function processCommandFile(filePath) {
  try {
    console.log('📁 Processing file:', filePath);

    if (!currentConfig || !currentConfig.ipAddress || !currentConfig.port) {
      throw new Error('Printer configuration not found');
    }

    // Read the command from the file
    const command = await fs.readFile(filePath, 'utf8');
    const trimmedCommand = command.trim();

    if (!trimmedCommand) {
      throw new Error('Empty command file');
    }

    console.log('📤 Sending command to printer:', trimmedCommand);

    // Send command to printer
    const result = await sendCommandToPrinter(currentConfig.ipAddress, currentConfig.port, trimmedCommand, currentConfig.timeout || 10000);

    // Create response file with same name but .ANS extension
    const responseFilePath = filePath.replace(/\.[^/.]+$/, '.ANS');

    if (result.success) {
      await fs.writeFile(responseFilePath, result.response || 'OK', 'utf8');
      console.log('✅ Command sent to printer successfully:', filePath);
      console.log('💾 Response saved as:', path.basename(responseFilePath));

      // Send log to renderer
      if (mainWindow) {
        mainWindow.webContents.send('file-processed', {
          file: path.basename(filePath),
          command: trimmedCommand,
          response: result.response || 'OK',
          success: true
        });
      }
    } else {
      await fs.writeFile(responseFilePath, `ERROR: ${result.error}`, 'utf8');
      console.error('❌ Command failed:', result.error);

      // Send log to renderer
      if (mainWindow) {
        mainWindow.webContents.send('file-processed', {
          file: path.basename(filePath),
          command: trimmedCommand,
          response: `ERROR: ${result.error}`,
          success: false
        });
      }
    }

    // Delete the original command file
    await fs.remove(filePath);
    console.log('🗑️ Deleted original file:', path.basename(filePath));

  } catch (error) {
    console.error('Error processing file:', filePath, error);

    // Create error response file
    try {
      const responseFilePath = filePath.replace(/\.[^/.]+$/, '.ANS');
      await fs.writeFile(responseFilePath, `ERROR: ${error.message}`, 'utf8');
      await fs.remove(filePath);
    } catch (cleanupError) {
      console.error('Error during cleanup:', cleanupError);
    }

    // Send error log to renderer
    if (mainWindow) {
      mainWindow.webContents.send('file-processed', {
        file: path.basename(filePath),
        command: 'Unknown',
        response: `ERROR: ${error.message}`,
        success: false
      });
    }
  }
}

function startFileWatcher(watchPath) {
  console.log('Starting file watcher for:', watchPath);

  if (fileWatcher) {
    fileWatcher.close();
  }

  // Watch for .txt files in the specified directory
  fileWatcher = chokidar.watch(watchPath, {
    ignored: /^\./, // ignore dotfiles
    persistent: true,
    ignoreInitial: false, // Process existing files on startup
    awaitWriteFinish: {
      stabilityThreshold: 500, // Wait 500ms after file write finishes
      pollInterval: 100
    }
  });

  fileWatcher
    .on('add', (filePath) => {
      console.log('New file detected:', filePath);
      // Only process .txt files
      if (path.extname(filePath).toLowerCase() === '.txt') {
        processCommandFile(filePath);
      }
    })
    .on('error', (error) => {
      console.error('File watcher error:', error);
      if (mainWindow) {
        mainWindow.webContents.send('watcher-error', error.message);
      }
    });

  isResidentModeActive = true;

  if (mainWindow) {
    mainWindow.webContents.send('resident-mode-status', { active: true, path: watchPath });
  }
}

function stopFileWatcher() {
  console.log('Stopping file watcher');

  if (fileWatcher) {
    fileWatcher.close();
    fileWatcher = null;
  }

  isResidentModeActive = false;

  if (mainWindow) {
    mainWindow.webContents.send('resident-mode-status', { active: false });
  }
}


// Helper function to send command to printer - with aggressive info query support
function sendCommandToPrinter(host, port, command, timeout = 3000) {
  return new Promise((resolve) => {
    const socket = new net.Socket();
    let responseData = Buffer.alloc(0);
    let resolved = false;

    // Check if this is an info/status query command that might return data
    const isInfoCommand = command.match(/^(90|91|92|95|96|97|98|99|N|V|S)/i);
    const expectResponse = isInfoCommand;
    const responseTimeout = expectResponse ? 10000 : timeout; // Longer timeout for info commands

    const cleanupAndResolve = (result) => {
      if (resolved) return;
      resolved = true;
      clearTimeout(timer);
      socket.destroy();
      resolve(result);
    };

    const timer = setTimeout(() => {
      if (expectResponse) {
        const responseStr = responseData.toString('utf8').trim();
        console.log(`⏰ Info command timeout - partial response: "${responseStr}"`);
        if (responseStr.length > 0) {
          // If we got partial data, return it as success
          cleanupAndResolve({
            success: true,
            response: responseStr,
            command: command
          });
        } else {
          cleanupAndResolve({
            success: false,
            response: 'No response received',
            error: 'Timeout waiting for device info',
            command: command
          });
        }
      } else {
        console.log(`⏰ Command timeout - treating as successful for serial bridge`);
        cleanupAndResolve({
          success: true,
          response: responseData.toString('utf8').trim() || 'Command sent successfully',
          command: command
        });
      }
    }, responseTimeout);

    socket.setTimeout(responseTimeout);

    socket.connect(port, host, () => {
      console.log(`🔗 Connected to printer at ${host}:${port}`);

      if (expectResponse) {
        console.log(`🔍 Info command detected - using discovered packet protocol`);

        // Use the working packet format discovered in terminal tests
        // Format: STX (0x02) + COMMAND + ETX (0x03)
        let packetCommand;

        if (command.toUpperCase() === 'N') {
          // Serial number request
          packetCommand = Buffer.from([0x02, 0x4E, 0x03]); // STX + N + ETX
        } else if (command === '90') {
          // Status command in packet format
          packetCommand = Buffer.from([0x02, 0x39, 0x30, 0x03]); // STX + "90" + ETX
        } else {
          // Convert single character commands to packet format
          const cmdByte = command.charCodeAt(0);
          packetCommand = Buffer.from([0x02, cmdByte, 0x03]); // STX + CMD + ETX
        }

        console.log(`📤 Sending packet: ${Array.from(packetCommand).map(b => `\\x${b.toString(16).padStart(2, '0')}`).join('')}`);
        socket.write(packetCommand);
      } else {
        // Standard command for non-info commands
        const commandToSend = command + '\r\n';
        socket.write(commandToSend, 'utf8');
        console.log(`📤 Sent command: "${command}" + CR+LF (${commandToSend.length} bytes)`);

        setTimeout(() => {
          if (!resolved) {
            console.log(`📋 No response expected - command likely executed`);
            cleanupAndResolve({
              success: true,
              response: responseData.toString('utf8').trim() || 'Command executed',
              command: command
            });
          }
        }, 1000);
      }
    });

    socket.on('data', (data) => {
      responseData = Buffer.concat([responseData, data]);

      // Display binary data in hex format
      const hexStr = Array.from(data).map(b => b.toString(16).padStart(2, '0')).join(' ');
      console.log(`📥 Received ${data.length} bytes (hex): ${hexStr}`);

      // Also try to display as text (for debugging)
      const dataStr = data.toString('utf8');
      console.log(`📥 Received as text: "${dataStr.replace(/\r/g, '\\r').replace(/\n/g, '\\n')}"`);

      if (expectResponse) {
        // For info commands, accept ANY data as a valid response immediately
        if (responseData.length > 0) {
          const hexResponse = Array.from(responseData).map(b => b.toString(16).padStart(2, '0')).join(' ');
          console.log(`📥 Binary response received - hex: ${hexResponse}`);

          // Check if we got the expected "16 15" response (hex)
          if (responseData.length >= 2 && responseData[0] === 0x16 && responseData[1] === 0x15) {
            console.log(`✅ Got expected 16 15 response - device communication established!`);
            cleanupAndResolve({
              success: true,
              response: `Device Status: 16 15 (hex) - Communication established! This matches the terminal test results.`,
              command: command,
              rawResponse: hexResponse
            });
          } else {
            // Handle other binary or text responses immediately
            console.log(`✅ Device response received - processing as binary`);
            const totalStr = responseData.toString('utf8');
            cleanupAndResolve({
              success: true,
              response: totalStr.trim() || `Binary response: ${hexResponse}`,
              command: command,
              rawResponse: hexResponse
            });
          }
        }
      } else {
        // For regular commands, any response is good
        const totalStr = responseData.toString('utf8');
        if (totalStr.trim().length > 0) {
          console.log(`✅ Response received: "${totalStr.trim()}"`);
          cleanupAndResolve({
            success: true,
            response: totalStr.trim(),
            command: command
          });
        }
      }
    });

    socket.on('error', (error) => {
      console.log(`❌ Socket error: ${error.message}`);
      cleanupAndResolve({ success: false, error: error.message });
    });

    socket.on('close', () => {
      const responseStr = responseData.toString('utf8').trim();
      console.log(`🔌 Socket closed, response: "${responseStr}"`);
      if (!resolved) {
        if (expectResponse && responseStr.length > 0) {
          cleanupAndResolve({
            success: true,
            response: responseStr,
            command: command
          });
        } else if (!expectResponse) {
          cleanupAndResolve({
            success: true,
            response: responseStr || 'Command sent to printer',
            command: command
          });
        } else {
          cleanupAndResolve({
            success: false,
            error: 'Connection closed without response',
            response: responseStr,
            command: command
          });
        }
      }
    });

    socket.on('timeout', () => {
      const responseStr = responseData.toString('utf8').trim();
      console.log(`⏰ Socket timeout, response so far: "${responseStr}"`);
      if (!resolved) {
        if (expectResponse && responseStr.length > 0) {
          cleanupAndResolve({
            success: true,
            response: responseStr,
            command: command
          });
        } else if (expectResponse) {
          cleanupAndResolve({
            success: false,
            error: 'Timeout waiting for response',
            response: responseStr,
            command: command
          });
        } else {
          cleanupAndResolve({
            success: true,
            response: responseStr || 'Command sent successfully',
            command: command
          });
        }
      }
    });
  });
}

// IPC handlers for main process functionality

// Configuration management
const configPath = path.join(os.homedir(), '.datecs-settings');

ipcMain.handle('load-config', async () => {
  try {
    if (await fs.pathExists(configPath)) {
      const config = await fs.readJson(configPath);
      currentConfig = config; // Store globally for file processing
      return { success: true, config };
    } else {
      return { success: false, error: 'Config file not found' };
    }
  } catch (error) {
    return { success: false, error: error.message };
  }
});

ipcMain.handle('save-config', async (event, config) => {
  try {
    await fs.writeJson(configPath, config, { spaces: 2 });
    currentConfig = config; // Update global config
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

// TCP communication
ipcMain.handle('test-connection', async (event, { host, port, timeout = 10000 }) => {
  return new Promise((resolve) => {
    const socket = new net.Socket();

    const timer = setTimeout(() => {
      socket.destroy();
      resolve({ success: false, error: 'Connection timeout' });
    }, timeout);

    socket.connect(port, host, () => {
      clearTimeout(timer);
      socket.destroy();
      resolve({ success: true, message: 'Connection successful' });
    });

    socket.on('error', (error) => {
      clearTimeout(timer);
      resolve({ success: false, error: error.message });
    });
  });
});


ipcMain.handle('send-command', async (event, { host, port, command, timeout = 10000 }) => {
  return new Promise((resolve) => {
    const socket = new net.Socket();
    let responseData = '';

    const timer = setTimeout(() => {
      socket.destroy();
      resolve({ success: false, error: 'Command timeout' });
    }, timeout);

    socket.connect(port, host, () => {
      // Send command with CR+LF terminator
      socket.write(command + '\r\n');
    });

    socket.on('data', (data) => {
      responseData += data.toString();

      // Check if we have a complete response (ends with CR or LF)
      if (responseData.includes('\r') || responseData.includes('\n')) {
        clearTimeout(timer);
        socket.destroy();
        resolve({
          success: true,
          response: responseData.trim(),
          command: command
        });
      }
    });

    socket.on('error', (error) => {
      clearTimeout(timer);
      resolve({ success: false, error: error.message });
    });

    socket.on('close', () => {
      clearTimeout(timer);
      if (responseData) {
        resolve({
          success: true,
          response: responseData.trim(),
          command: command
        });
      }
    });
  });
});

// File system operations
ipcMain.handle('create-directories', async (event, paths) => {
  try {
    for (const dirPath of paths) {
      await fs.ensureDir(dirPath);
    }
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

ipcMain.handle('write-file', async (event, { filePath, content }) => {
  try {
    await fs.writeFile(filePath, content);
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

ipcMain.handle('read-file', async (event, filePath) => {
  try {
    const content = await fs.readFile(filePath, 'utf8');
    return { success: true, content };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

// Get system info
ipcMain.handle('get-system-info', async () => {
  return {
    platform: process.platform,
    homedir: os.homedir(),
    configPath: configPath
  };
});

// File watching IPC handlers
ipcMain.handle('start-resident-mode', async (event, watchPath) => {
  try {
    if (!watchPath) {
      throw new Error('Watch path is required');
    }

    if (!currentConfig) {
      throw new Error('Please configure printer settings first');
    }

    // Ensure the directory exists
    await fs.ensureDir(watchPath);

    startFileWatcher(watchPath);
    return { success: true, message: `Resident mode started. Watching: ${watchPath}` };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

ipcMain.handle('stop-resident-mode', async () => {
  try {
    stopFileWatcher();
    return { success: true, message: 'Resident mode stopped' };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

ipcMain.handle('get-resident-mode-status', async () => {
  return {
    active: isResidentModeActive,
    hasConfig: !!currentConfig
  };
});

// Folder picker dialog
ipcMain.handle('select-folder', async () => {
  try {
    const result = await dialog.showOpenDialog(mainWindow, {
      properties: ['openDirectory'],
      title: 'Select Watch Folder'
    });

    if (result.canceled) {
      return { success: false, canceled: true };
    }

    return { success: true, folderPath: result.filePaths[0] };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

// Clean up file watcher when app is closing
app.on('before-quit', () => {
  if (fileWatcher) {
    fileWatcher.close();
  }
});
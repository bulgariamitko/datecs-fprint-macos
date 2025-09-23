const { app, BrowserWindow, Menu, ipcMain } = require('electron');
const path = require('path');
const isDev = process.env.ELECTRON_IS_DEV === 'true';
const fs = require('fs-extra');
const net = require('net');
const os = require('os');

let mainWindow;

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

// IPC handlers for main process functionality

// Configuration management
const configPath = path.join(os.homedir(), 'Documents', 'DatecsFPrint.config');

ipcMain.handle('load-config', async () => {
  try {
    if (await fs.pathExists(configPath)) {
      const config = await fs.readJson(configPath);
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
      socket.write(command + '\\r\\n');
    });

    socket.on('data', (data) => {
      responseData += data.toString();

      // Check if we have a complete response (ends with CR or LF)
      if (responseData.includes('\\r') || responseData.includes('\\n')) {
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
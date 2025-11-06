import React, { useState, useEffect } from 'react';
import { Play, Square, FolderOpen, FileText, AlertCircle, CheckCircle } from 'lucide-react';
import InfoTooltip from './InfoTooltip';

const { ipcRenderer } = window.require('electron');

const ResidentMode = ({ config, onLog }) => {
  const [isActive, setIsActive] = useState(false);
  const [watchPath, setWatchPath] = useState(config.watchFolder || '');
  const [isStarting, setIsStarting] = useState(false);
  const [isStopping, setIsStopping] = useState(false);
  const [connectionStatus, setConnectionStatus] = useState('disconnected');

  useEffect(() => {
    // Check initial status
    checkStatus();

    // Listen for file processing updates
    const handleFileProcessed = (event, data) => {
      if (data.success) {
        onLog(`📄 File processed: ${data.file}`, 'success');
        onLog(`📤 Command sent: ${data.command}`, 'info');
        onLog(`📥 Response: ${data.response}`, 'success');
        onLog(`🗑️ File deleted: ${data.file}`, 'info');
      } else {
        onLog(`❌ Failed: ${data.file} -> ${data.response}`, 'error');
      }
    };

    const handleResidentModeStatus = (event, data) => {
      setIsActive(data.active);
      if (data.path) {
        setWatchPath(data.path);
      }
    };

    const handleWatcherError = (event, error) => {
      onLog(`🚨 File watcher error: ${error}`, 'error');
    };

    ipcRenderer.on('file-processed', handleFileProcessed);
    ipcRenderer.on('resident-mode-status', handleResidentModeStatus);
    ipcRenderer.on('watcher-error', handleWatcherError);

    return () => {
      ipcRenderer.removeListener('file-processed', handleFileProcessed);
      ipcRenderer.removeListener('resident-mode-status', handleResidentModeStatus);
      ipcRenderer.removeListener('watcher-error', handleWatcherError);
    };
  }, [onLog]);

  useEffect(() => {
    setWatchPath(config.watchFolder || '');
  }, [config.watchFolder]);

  const checkStatus = async () => {
    try {
      const result = await ipcRenderer.invoke('get-resident-mode-status');
      setIsActive(result.active);
    } catch (error) {
      console.error('Error checking resident mode status:', error);
    }
  };

  const selectFolder = async () => {
    try {
      const result = await ipcRenderer.invoke('select-folder');
      if (result.success && result.folderPath) {
        setWatchPath(result.folderPath);
        onLog(`📁 Selected folder: ${result.folderPath}`, 'info');
      }
    } catch (error) {
      onLog(`❌ Error selecting folder: ${error.message}`, 'error');
    }
  };

  const testConnection = async () => {
    if (!config.ipAddress || !config.port) {
      onLog('❌ Please configure IP address and port first', 'error');
      return false;
    }

    setConnectionStatus('testing');
    onLog(`Testing connection to ${config.ipAddress}:${config.port}...`, 'info');

    try {
      const result = await ipcRenderer.invoke('test-connection', {
        host: config.ipAddress,
        port: parseInt(config.port),
        timeout: config.timeout
      });

      if (result.success) {
        setConnectionStatus('connected');
        onLog('✅ Connection successful!', 'success');
        return true;
      } else {
        setConnectionStatus('disconnected');
        onLog(`❌ Connection failed: ${result.error}`, 'error');
        return false;
      }
    } catch (error) {
      setConnectionStatus('disconnected');
      onLog(`❌ Connection error: ${error.message}`, 'error');
      return false;
    }
  };

  const startResidentMode = async () => {
    if (!watchPath.trim()) {
      onLog('❌ Please select a watch folder', 'error');
      return;
    }

    setIsStarting(true);

    try {
      // First test connection
      onLog('🔄 Testing printer connection...', 'info');
      const connectionOk = await testConnection();

      if (!connectionOk) {
        onLog('❌ Cannot start resident mode: Connection test failed', 'error');
        setIsStarting(false);
        return;
      }

      // Connection successful, start file watching
      const result = await ipcRenderer.invoke('start-resident-mode', watchPath.trim());
      if (result.success) {
        setIsActive(true);
        onLog(`🚀 ${result.message}`, 'success');
      } else {
        onLog(`❌ Failed to start resident mode: ${result.error}`, 'error');
      }
    } catch (error) {
      onLog(`❌ Error starting resident mode: ${error.message}`, 'error');
    } finally {
      setIsStarting(false);
    }
  };

  const stopResidentMode = async () => {
    setIsStopping(true);
    try {
      const result = await ipcRenderer.invoke('stop-resident-mode');
      if (result.success) {
        setIsActive(false);
        onLog(`⏹️ ${result.message}`, 'info');
      } else {
        onLog(`❌ Failed to stop resident mode: ${result.error}`, 'error');
      }
    } catch (error) {
      onLog(`❌ Error stopping resident mode: ${error.message}`, 'error');
    } finally {
      setIsStopping(false);
    }
  };

  const isConfigured = config.ipAddress && config.port && config.deviceModel && config.serialNumber;

  if (!isConfigured) {
    return (
      <div className="text-center py-8">
        <AlertCircle className="w-12 h-12 text-yellow-500 mx-auto mb-4" />
        <h3 className="text-lg font-medium mb-2">Configuration Required</h3>
        <p className="text-muted mb-4">
          Please configure your printer settings before using resident mode.
        </p>
      </div>
    );
  }

  return (
    <div>
      <h2 className="mb-4">Resident Mode (File Watcher)</h2>

      {/* Status Display */}
      <div className="mb-6 p-4 bg-gray-50 rounded-lg">
        <div className="flex items-center gap-3 mb-3">
          {isActive ? (
            <CheckCircle className="w-5 h-5 text-green-600" />
          ) : (
            <AlertCircle className="w-5 h-5 text-gray-400" />
          )}
          <span className={`font-medium ${isActive ? 'text-green-600' : 'text-gray-600'}`}>
            {isActive ? 'Active - Monitoring for files' : 'Inactive'}
          </span>
        </div>

        {isActive && (
          <div className="text-sm text-muted">
            <FolderOpen className="w-4 h-4 inline mr-1" />
            Watching: {watchPath}
          </div>
        )}

      </div>

      {/* Watch Folder Configuration */}
      <div className="mb-6">
        <label className="block text-sm font-medium mb-2 flex items-center">
          Watch Folder
          <InfoTooltip content="Select the folder where you want to drop .txt files containing printer commands. The app will automatically process these files and send them to your printer." />
        </label>
        <div className="flex gap-2">
          <input
            type="text"
            value={watchPath}
            onChange={(e) => setWatchPath(e.target.value)}
            placeholder="Select a folder..."
            className="flex-1"
            disabled={isActive}
            readOnly
          />
          <button
            className="btn btn-secondary"
            onClick={selectFolder}
            disabled={isActive}
          >
            <FolderOpen className="w-4 h-4" />
            Browse
          </button>
        </div>
      </div>

      {/* Control Buttons */}
      <div className="flex gap-3 mb-6">
        {!isActive ? (
          <button
            className="btn btn-success"
            onClick={startResidentMode}
            disabled={isStarting || !watchPath.trim()}
          >
            {isStarting ? (
              <>
                <div className="spinner" />
                Starting...
              </>
            ) : (
              <>
                <Play className="w-4 h-4" />
                Start Resident Mode
              </>
            )}
          </button>
        ) : (
          <button
            className="btn btn-danger"
            onClick={stopResidentMode}
            disabled={isStopping}
          >
            {isStopping ? (
              <>
                <div className="spinner" />
                Stopping...
              </>
            ) : (
              <>
                <Square className="w-4 h-4" />
                Stop Resident Mode
              </>
            )}
          </button>
        )}
      </div>

      {/* Quick Help */}
      <div className="flex items-center gap-2 text-sm text-muted">
        <FileText className="w-4 h-4" />
        <span>How it works:</span>
        <InfoTooltip content={
          <div>
            <strong>Resident Mode Process:</strong>
            <ol className="mt-2 space-y-1">
              <li>1. Drop .txt files with printer commands into the watch folder</li>
              <li>2. Files are automatically processed and sent to the printer</li>
              <li>3. Response is saved as .ANS file with the same name</li>
              <li>4. Original .txt file is deleted after processing</li>
            </ol>
            <div className="mt-3 p-2 bg-gray-100 rounded text-xs">
              <strong>Example:</strong> Create "test.txt" containing "I,1,______,_,__;0;80"<br/>
              → Response saved as "test.ANS" → "test.txt" deleted
            </div>
          </div>
        } />
      </div>
    </div>
  );
};

export default ResidentMode;
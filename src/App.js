import React, { useState, useEffect } from 'react';
import { Printer, Settings, Play, CheckCircle, XCircle, Loader } from 'lucide-react';
import ConfigurationPanel from './components/ConfigurationPanel';
import ConnectionTester from './components/ConnectionTester';
import LogViewer from './components/LogViewer';

const { ipcRenderer } = window.require('electron');

function App() {
  const [config, setConfig] = useState({
    ipAddress: '192.168.1.155',
    port: 4999,
    deviceModel: 'DP-25MX',
    serialNumber: 'DA020990',
    fiscalMemoryNumber: '79020990',
    country: 'Bulgaria',
    timeout: 10000
  });

  const [connectionStatus, setConnectionStatus] = useState('disconnected');
  const [logs, setLogs] = useState([]);
  const [isConfigured, setIsConfigured] = useState(false);
  const [activeTab, setActiveTab] = useState('connection');

  // Load configuration on startup
  useEffect(() => {
    loadConfiguration();
  }, []);

  // Check if configuration is complete
  useEffect(() => {
    const required = ['ipAddress', 'deviceModel', 'serialNumber'];
    const configured = required.every(field => config[field] && config[field].trim() !== '');
    setIsConfigured(configured);
  }, [config]);

  const addLog = (message, level = 'info') => {
    const timestamp = new Date().toLocaleTimeString();
    setLogs(prev => [...prev, { id: Date.now(), timestamp, message, level }]);
  };

  const loadConfiguration = async () => {
    try {
      const result = await ipcRenderer.invoke('load-config');
      if (result.success) {
        setConfig(result.config);
        addLog('Configuration loaded successfully', 'success');
      } else {
        addLog('No existing configuration found, using defaults', 'info');
      }
    } catch (error) {
      addLog(`Error loading configuration: ${error.message}`, 'error');
    }
  };

  const saveConfiguration = async (newConfig) => {
    try {
      const result = await ipcRenderer.invoke('save-config', newConfig);
      if (result.success) {
        setConfig(newConfig);
        addLog('Configuration saved successfully', 'success');
      } else {
        addLog(`Error saving configuration: ${result.error}`, 'error');
      }
    } catch (error) {
      addLog(`Error saving configuration: ${error.message}`, 'error');
    }
  };

  const testConnection = async () => {
    if (!config.ipAddress || !config.port) {
      addLog('Please configure IP address and port first', 'error');
      return;
    }

    setConnectionStatus('testing');
    addLog(`Testing connection to ${config.ipAddress}:${config.port}...`, 'info');

    try {
      const result = await ipcRenderer.invoke('test-connection', {
        host: config.ipAddress,
        port: parseInt(config.port),
        timeout: config.timeout
      });

      if (result.success) {
        setConnectionStatus('connected');
        addLog('✅ Connection successful!', 'success');
      } else {
        setConnectionStatus('disconnected');
        addLog(`❌ Connection failed: ${result.error}`, 'error');
      }
    } catch (error) {
      setConnectionStatus('disconnected');
      addLog(`❌ Connection error: ${error.message}`, 'error');
    }
  };

  const sendTestCommand = async () => {
    if (connectionStatus !== 'connected') {
      addLog('Please test connection first', 'error');
      return;
    }

    const testCommand = 'I,1,______,_,__;0;80';
    addLog(`Sending test command: ${testCommand}`, 'info');

    try {
      const result = await ipcRenderer.invoke('send-command', {
        host: config.ipAddress,
        port: parseInt(config.port),
        command: testCommand,
        timeout: config.timeout
      });

      if (result.success) {
        addLog(`📥 Response: ${result.response}`, 'success');

        // Check if response contains our printer's serial numbers
        if (result.response.includes(config.serialNumber) ||
            result.response.includes(config.fiscalMemoryNumber)) {
          addLog('🎯 Confirmed: This is your configured printer!', 'success');
        }
      } else {
        addLog(`❌ Command failed: ${result.error}`, 'error');
      }
    } catch (error) {
      addLog(`❌ Command error: ${error.message}`, 'error');
    }
  };

  const getStatusIndicator = () => {
    switch (connectionStatus) {
      case 'connected':
        return <CheckCircle className="w-4 h-4 text-green-600" />;
      case 'testing':
        return <Loader className="w-4 h-4 text-yellow-600 animate-spin" />;
      default:
        return <XCircle className="w-4 h-4 text-red-600" />;
    }
  };

  const getStatusText = () => {
    switch (connectionStatus) {
      case 'connected':
        return 'Connected';
      case 'testing':
        return 'Testing...';
      default:
        return 'Disconnected';
    }
  };

  const getStatusClass = () => {
    switch (connectionStatus) {
      case 'connected':
        return 'status-connected';
      case 'testing':
        return 'status-testing';
      default:
        return 'status-disconnected';
    }
  };

  return (
    <div className="app">
      {/* Header */}
      <header className="header">
        <div className="flex items-center gap-2">
          <Printer className="w-6 h-6" />
          <div>
            <h1>DatecsFPrint for macOS</h1>
            <p>Electron + React desktop app for Datecs fiscal printers</p>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="main-content">
        {/* Status Bar */}
        <div className="card">
          <div className="flex justify-between items-center">
            <div className="flex items-center gap-4">
              <div className={`status ${getStatusClass()}`}>
                {getStatusIndicator()}
                {getStatusText()}
              </div>
              {isConfigured && (
                <div className="text-muted">
                  {config.deviceModel} • {config.ipAddress}:{config.port}
                </div>
              )}
            </div>

            {isConfigured && (
              <div className="flex gap-2">
                <button
                  className="btn btn-primary"
                  onClick={testConnection}
                  disabled={connectionStatus === 'testing'}
                >
                  {connectionStatus === 'testing' ? (
                    <>
                      <Loader className="w-4 h-4 animate-spin" />
                      Testing...
                    </>
                  ) : (
                    <>
                      <Play className="w-4 h-4" />
                      Test Connection
                    </>
                  )}
                </button>

                {connectionStatus === 'connected' && (
                  <button
                    className="btn btn-success"
                    onClick={sendTestCommand}
                  >
                    Send Test Command
                  </button>
                )}
              </div>
            )}
          </div>
        </div>

        {/* Tab Navigation */}
        <div className="card">
          <div className="flex gap-4 mb-4">
            <button
              className={`btn ${activeTab === 'connection' ? 'btn-primary' : 'btn-secondary'}`}
              onClick={() => setActiveTab('connection')}
            >
              Connection Test
            </button>
            <button
              className={`btn ${activeTab === 'settings' ? 'btn-primary' : 'btn-secondary'}`}
              onClick={() => setActiveTab('settings')}
            >
              <Settings className="w-4 h-4" />
              Settings
            </button>
          </div>

          {/* Tab Content */}
          {activeTab === 'connection' && (
            <ConnectionTester
              config={config}
              connectionStatus={connectionStatus}
              onTestConnection={testConnection}
              onSendTestCommand={sendTestCommand}
              isConfigured={isConfigured}
            />
          )}

          {activeTab === 'settings' && (
            <ConfigurationPanel
              config={config}
              onSave={saveConfiguration}
            />
          )}
        </div>

        {/* Log Viewer */}
        <div className="card">
          <LogViewer logs={logs} onClear={() => setLogs([])} />
        </div>
      </main>
    </div>
  );
}

export default App;
import React from 'react';
import { Play, Send, AlertCircle, CheckCircle, Settings } from 'lucide-react';

const ConnectionTester = ({
  config,
  connectionStatus,
  onTestConnection,
  onSendTestCommand,
  isConfigured
}) => {
  if (!isConfigured) {
    return (
      <div className="text-center py-8">
        <AlertCircle className="w-12 h-12 text-yellow-500 mx-auto mb-4" />
        <h3 className="text-lg font-medium mb-2">Configuration Required</h3>
        <p className="text-muted mb-4">
          Please configure your printer settings before testing the connection.
        </p>
        <p className="text-sm text-muted mb-4">
          You need to set at least:
        </p>
        <ul className="text-sm text-muted text-left max-w-md mx-auto">
          <li>• IP Address</li>
          <li>• Device Model</li>
          <li>• Serial Number</li>
        </ul>
      </div>
    );
  }

  return (
    <div>
      <h2 className="mb-4">Connection Testing</h2>

      {/* Current Configuration Display */}
      <div className="mb-6 p-4 bg-gray-50 rounded-lg">
        <h3 className="font-medium mb-2">Current Configuration:</h3>
        <div className="grid grid-2 gap-4 text-sm">
          <div>
            <strong>Device:</strong> {config.deviceModel}
          </div>
          <div>
            <strong>Connection:</strong> {config.ipAddress}:{config.port}
          </div>
          <div>
            <strong>Serial Number:</strong> {config.serialNumber}
          </div>
          <div>
            <strong>Fiscal Memory:</strong> {config.fiscalMemoryNumber || 'Not set'}
          </div>
        </div>
      </div>

      {/* Test Steps */}
      <div className="space-y-4">
        {/* Step 1: Basic Connection */}
        <div className="border rounded-lg p-4">
          <div className="flex items-center justify-between mb-3">
            <h3 className="font-medium flex items-center gap-2">
              <span className="w-6 h-6 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center text-sm font-bold">
                1
              </span>
              Test TCP Connection
            </h3>
            <button
              className="btn btn-primary"
              onClick={onTestConnection}
              disabled={connectionStatus === 'testing'}
            >
              {connectionStatus === 'testing' ? (
                <>
                  <div className="spinner" />
                  Testing...
                </>
              ) : (
                <>
                  <Play className="w-4 h-4" />
                  Test Connection
                </>
              )}
            </button>
          </div>
          <p className="text-sm text-muted">
            This tests if your Mac can connect to the printer on the network.
          </p>
          {connectionStatus === 'connected' && (
            <div className="mt-2 flex items-center gap-2 text-green-600">
              <CheckCircle className="w-4 h-4" />
              <span className="text-sm">Connection successful!</span>
            </div>
          )}
        </div>

        {/* Step 2: Send Test Command */}
        <div className="border rounded-lg p-4">
          <div className="flex items-center justify-between mb-3">
            <h3 className="font-medium flex items-center gap-2">
              <span className="w-6 h-6 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center text-sm font-bold">
                2
              </span>
              Send Test Command
            </h3>
            <button
              className="btn btn-success"
              onClick={onSendTestCommand}
              disabled={connectionStatus !== 'connected'}
            >
              <Send className="w-4 h-4" />
              Send Command
            </button>
          </div>
          <p className="text-sm text-muted">
            Sends a device information command (I,1,______,_,__;0;80) to verify printer communication.
          </p>
          {connectionStatus !== 'connected' && (
            <div className="mt-2 text-sm text-yellow-600">
              ⚠️ Complete step 1 first
            </div>
          )}
        </div>
      </div>

      {/* Test Commands Reference */}
      <div className="mt-6 p-4 bg-blue-50 rounded-lg">
        <h4 className="font-medium mb-2">Common Test Commands:</h4>
        <div className="text-sm text-muted space-y-1">
          <div><code>I,1,______,_,__;0;80</code> - Get device information</div>
          <div><code>N,1,______,_,__;</code> - Get last document number</div>
        </div>
        <p className="text-xs text-muted mt-2">
          These commands are safe to run and won't affect your printer's fiscal state.
        </p>
      </div>

      {/* Troubleshooting */}
      <div className="mt-6 p-4 bg-yellow-50 rounded-lg">
        <h4 className="font-medium mb-2">Troubleshooting:</h4>
        <ul className="text-sm text-muted space-y-1">
          <li>• Ensure printer is powered on and connected to network</li>
          <li>• Verify IP address is correct (check printer display/menu)</li>
          <li>• Check if port 4999 is accessible (standard for Datecs)</li>
          <li>• Confirm Mac and printer are on same network</li>
          <li>• Disable firewall temporarily if connection fails</li>
        </ul>
      </div>
    </div>
  );
};

export default ConnectionTester;
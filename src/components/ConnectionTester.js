import React from 'react';
import { Play, Send, AlertCircle, CheckCircle, Settings } from 'lucide-react';
import InfoTooltip from './InfoTooltip';

const ConnectionTester = ({
  config,
  connectionStatus,
  isConfigured,
  onManualTest,
  isManualTesting
}) => {
  if (!isConfigured) {
    return (
      <div className="text-center py-8">
        <AlertCircle className="w-12 h-12 text-yellow-500 mx-auto mb-4" />
        <h3 className="text-lg font-medium mb-2">Configuration Required</h3>
        <p className="text-muted mb-4">
          Configure your printer in Settings first.
        </p>
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

      {/* Connection Status Info */}
      <div className="border rounded-lg p-4">
        <h3 className="font-medium mb-3 flex items-center gap-2">
          <span className="w-6 h-6 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center text-sm font-bold">
            ⚡
          </span>
          Automatic Connection Monitoring
        </h3>
        <div className="flex items-center gap-2 mb-3">
          <span className="text-sm text-muted">Connection status is checked every 10 seconds</span>
          <InfoTooltip content="The app automatically monitors your printer connection every 10 seconds. No manual testing required - just configure your printer and the app will show real-time status." />
        </div>

        {connectionStatus === 'connected' && (
          <div className="flex items-center gap-2 text-green-600">
            <CheckCircle className="w-4 h-4" />
            <span className="text-sm">Printer is online and responding</span>
          </div>
        )}

        {connectionStatus === 'disconnected' && (
          <div className="flex items-center gap-2 text-red-600">
            <AlertCircle className="w-4 h-4" />
            <span className="text-sm">Printer is offline or unreachable</span>
          </div>
        )}

        {connectionStatus === 'testing' && (
          <div className="flex items-center gap-2 text-yellow-600">
            <div className="spinner" />
            <span className="text-sm">Checking connection...</span>
          </div>
        )}
      </div>

      {/* Manual Test Section */}
      <div className="border rounded-lg p-4 mt-4">
        <div className="flex items-center justify-between mb-3">
          <h3 className="font-medium flex items-center gap-2">
            <span className="w-6 h-6 bg-green-100 text-green-600 rounded-full flex items-center justify-center text-sm font-bold">
              🔧
            </span>
            Manual Connection Test
          </h3>
          <button
            className="btn btn-primary"
            onClick={onManualTest}
            disabled={isManualTesting}
          >
            {isManualTesting ? (
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
        <div className="flex items-center gap-2 mb-3">
          <span className="text-sm text-muted">Tests basic connection to the printer</span>
          <InfoTooltip content="This manual test connects to the printer and verifies that basic TCP communication is working." />
        </div>
      </div>

      {/* Help Section */}
      <div className="mt-6 flex items-center gap-4 text-sm text-muted">
        <span>Need help?</span>
        <InfoTooltip content="The connection test verifies that your Mac can reach the printer's IP address on the specified port. Make sure the printer is powered on and connected to the same network." />
        <InfoTooltip content={
          <div>
            <strong>Troubleshooting Tips:</strong>
            <ul className="mt-2 space-y-1">
              <li>• Ensure printer is powered on and connected to network</li>
              <li>• Verify IP address is correct (check printer display/menu)</li>
              <li>• Check if port 4999 is accessible (standard for Datecs)</li>
              <li>• Confirm Mac and printer are on same network</li>
              <li>• Disable firewall temporarily if connection fails</li>
            </ul>
          </div>
        } />
      </div>
    </div>
  );
};

export default ConnectionTester;